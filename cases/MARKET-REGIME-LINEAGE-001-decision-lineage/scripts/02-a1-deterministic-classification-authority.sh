#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="MARKET-REGIME-LINEAGE-001"
REVISION="A1-R1"

ROOT="$HOME/cmu/$CASE"
A0="$ROOT/stage-a0-r1"
STAGE="$ROOT/stage-a1-r1"
EVIDENCE="$STAGE/evidence"
AUTH="$STAGE/authorities"
RESULTS="$STAGE/results"
LOCK="$ROOT/.stage-a1-r1-execution-started"

EXPECTED_A0_MANIFEST_SHA256="0440ffea6e2377fa6843f972f35d127f44727f114c2d91ae94039ff1ca4a78c8"
EXPECTED_SNAPSHOT_A_SHA256="10ce61f2bd18d1f32191a91c317759a87ca11b993f22f630818c56a96bef9410"
EXPECTED_SNAPSHOT_B_SHA256="d1688f9b362c84018f9fc093e8a6f7b985e56e3965bdb9bf8d2bdffa3af39a34"
EXPECTED_SNAPSHOT_C_SHA256="b0604231b66c6d24ef7e640bb5cf423ed138984a69342eff0f2585ac446006c2"

EXPECTED_CONTRACT_SHA256="955b9bde32a74c46c100bba300a7c6398606b53c13efa237b97e3f076f53a2d5"
EXPECTED_AUTHORITY_1_SOURCE_SHA256="0e72cfbdeee214a40ba439c56f161e782719753eabe01647b5b4ddf04c0aa1f5"
EXPECTED_AUTHORITY_2_SOURCE_SHA256="a8c43eb473f07a6c0a68ffbed4bf5022453dbd558e520dcf2889eddfdc45e5b0"

section()
{
    echo
    echo "============================================================"
    echo " $1"
    echo "============================================================"
}

sha()
{
    sha256sum "$1" | awk '{print $1}'
}

not_evaluated()
{
    echo
    echo "MARKET_REGIME_LINEAGE_001_STAGE_A1=NOT_EVALUATED"
    echo "A1_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

fail()
{
    echo
    echo "MARKET_REGIME_LINEAGE_001_STAGE_A1=FAIL"
    echo "A1_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

require_cmd()
{
    cmd="$1"
    label="$2"

    if command -v "$cmd" >/dev/null 2>&1
    then
        echo "$label=PASS"
    else
        echo "$label=FAIL"
        not_evaluated "TOOLCHAIN_DRIFT"
    fi
}

test ! -e "$LOCK" ||
    not_evaluated "A1_ONE_EXECUTION_POLICY_ALREADY_CONSUMED"

section "0. A0 AUTHORITY + TOOLCHAIN"

for pair in     "cc:CC"     "awk:AWK"     "sha256sum:SHA256SUM"     "cmp:CMP"     "diff:DIFF"     "grep:GREP"     "sed:SED"     "wc:WC"     "find:FIND"     "sort:SORT"     "xargs:XARGS"
do
    cmd="${pair%%:*}"
    label="${pair#*:}"
    require_cmd "$cmd" "$label"
done

test -f "$A0/evidence/SHA256SUMS" ||
    not_evaluated "A0_EVIDENCE_MISSING"

test "$(sha "$A0/evidence/SHA256SUMS")" = "$EXPECTED_A0_MANIFEST_SHA256" ||
    not_evaluated "A0_EVIDENCE_IDENTITY_MISMATCH"

(
    cd "$A0"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || not_evaluated "A0_EVIDENCE_INTEGRITY_FAILURE"

test "$(sha "$A0/snapshots/state-A.tsv")" = "$EXPECTED_SNAPSHOT_A_SHA256" ||
    not_evaluated "A0_SNAPSHOT_IDENTITY_MISMATCH"

test "$(sha "$A0/snapshots/state-B.tsv")" = "$EXPECTED_SNAPSHOT_B_SHA256" ||
    not_evaluated "A0_SNAPSHOT_IDENTITY_MISMATCH"

test "$(sha "$A0/snapshots/state-C.tsv")" = "$EXPECTED_SNAPSHOT_C_SHA256" ||
    not_evaluated "A0_SNAPSHOT_IDENTITY_MISMATCH"

echo "A0_EVIDENCE_AUTHORITY=PASS"
echo "A0_SNAPSHOT_A_AUTHORITY=PASS"
echo "A0_SNAPSHOT_B_AUTHORITY=PASS"
echo "A0_SNAPSHOT_C_AUTHORITY=PASS"

section "1. MATERIALIZE FROZEN CLASSIFICATION AUTHORITIES"

rm -rf "$STAGE"
mkdir -p "$EVIDENCE" "$AUTH" "$RESULTS"

cat > "$STAGE/classification-contract.txt" <<'CONTRACT_EOF'
CASE=MARKET-REGIME-LINEAGE-001
CONTRACT=DETERMINISTIC-MARKET-REGIME-V1
CLASSIFIER_TYPE=EXPERIMENTAL
CLASSIFIER_DETERMINISTIC=YES
MARKET_TRUTH_CLAIM=NO
FORECASTING_CLAIM=NO
INVESTMENT_CLAIM=NO
INPUT_SCHEMA=evaluation_date,series_id,observation_date,vintage_date,value,units
FIXED_POINT_SCALE=10000
DECIMAL_PARSE=OPTIONAL_SIGN_PLUS_ONE_OR_MORE_DIGITS_PLUS_OPTIONAL_DOT_PLUS_ONE_TO_FOUR_DIGITS
DECIMAL_PADDING=RIGHT_ZERO_PAD_TO_FOUR_FRACTION_DIGITS
MORE_THAN_FOUR_FRACTION_DIGITS=INVALID
VIX_THRESHOLD_SCALED=200000
DGS10_THRESHOLD_SCALED=40000
NFCI_THRESHOLD_SCALED=0
COMPARISON_SEMANTICS=GREATER_THAN_OR_EQUAL
VIX_FLAG=1_IF_VIXCLS_GE_20_0000_ELSE_0
RATE_FLAG=1_IF_DGS10_GE_4_0000_ELSE_0
NFCI_FLAG=1_IF_NFCI_GE_0_0000_ELSE_0
SCORE=VIX_FLAG_PLUS_RATE_FLAG_PLUS_NFCI_FLAG
SCORE_0=CALM
SCORE_1=FRAGILE
SCORE_2=STRESSED
SCORE_3=STRESSED
MISSING_VALUE=INVALID
DUPLICATE_SERIES=INVALID
UNKNOWN_SERIES=INVALID
STATE_ROW_COUNT=EXACTLY_3
AUTHORITY_1=C11
AUTHORITY_2=POSIX_AWK_SHELL
SHARED_CLASSIFICATION_CODE=NO
THRESHOLD_TUNING_AFTER_DATA=FORBIDDEN
CONTRACT_EOF

cat > "$AUTH/authority-1-c11.c" <<'C11_EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
static int parse_fixed4(const char*s,long long*out){int sign=1,fd=0,sd=0;const char*p=s;long long w=0,f=0;if(*p=='+')p++;else if(*p=='-'){sign=-1;p++;}while(*p>='0'&&*p<='9'){sd=1;if(w>(LLONG_MAX-9)/10)return 0;w=w*10+(*p-'0');p++;}if(!sd)return 0;if(*p=='.'){p++;while(*p>='0'&&*p<='9'){if(fd>=4)return 0;f=f*10+(*p-'0');fd++;p++;}}if(*p!='\0')return 0;while(fd<4){f*=10;fd++;}if(w>(LLONG_MAX-f)/10000)return 0;*out=sign*(w*10000+f);return 1;}
static int split6(char*l,char**f){int n=0;char*p=l;f[n++]=p;while(*p){if(*p=='\t'){*p='\0';if(n>=6)return 0;f[n++]=p+1;}p++;}return n==6;}
int main(int argc,char**argv){FILE*fp;char line[4096],*f[6],date[11]={0};long long d=0,n=0,v=0,x;int hd=0,hn=0,hv=0,rows=0,rf,nf,vf,score;const char*lab;if(argc!=3||strlen(argv[1])!=1||!strchr("ABC",argv[1][0]))return 2;if(!(fp=fopen(argv[2],"r")))return 3;if(!fgets(line,sizeof line,fp)){fclose(fp);return 4;}line[strcspn(line,"\r\n")]='\0';if(strcmp(line,"evaluation_date\tseries_id\tobservation_date\tvintage_date\tvalue\tunits")){fclose(fp);return 5;}while(fgets(line,sizeof line,fp)){line[strcspn(line,"\r\n")]='\0';if(!*line)continue;if(!split6(line,f)){fclose(fp);return 6;}if(strlen(f[0])!=10){fclose(fp);return 7;}if(!*date)memcpy(date,f[0],11);else if(strcmp(date,f[0])){fclose(fp);return 8;}if(!parse_fixed4(f[4],&x)){fclose(fp);return 9;}if(!strcmp(f[1],"DGS10")){if(hd||strcmp(f[5],"percent")){fclose(fp);return 10;}d=x;hd=1;}else if(!strcmp(f[1],"NFCI")){if(hn||strcmp(f[5],"index")){fclose(fp);return 11;}n=x;hn=1;}else if(!strcmp(f[1],"VIXCLS")){if(hv||strcmp(f[5],"index")){fclose(fp);return 12;}v=x;hv=1;}else{fclose(fp);return 13;}rows++;}fclose(fp);if(rows!=3||!hd||!hn||!hv)return 14;rf=d>=40000;nf=n>=0;vf=v>=200000;score=rf+nf+vf;lab=score==0?"CALM":score==1?"FRAGILE":"STRESSED";printf("%s\t%s\t%lld\t%lld\t%lld\t%d\t%d\t%d\t%d\t%s\n",argv[1],date,d,n,v,rf,nf,vf,score,lab);return 0;}
C11_EOF

cat > "$AUTH/authority-2-posix.awk" <<'AWK_EOF'
BEGIN{FS="\t";OFS="\t";rows=0;hd=hn=hv=0}
function bad(c){exit c}
function fixed4(s,sign,b,a,k,w,f){sign=1;b=s;if(substr(b,1,1)=="+")b=substr(b,2);else if(substr(b,1,1)=="-"){sign=-1;b=substr(b,2)}if(b!~/^[0-9]+([.][0-9]+)?$/)bad(20);k=split(b,a,".");w=a[1]+0;f=(k==2?a[2]:"");if(length(f)>4)bad(21);while(length(f)<4)f=f"0";if(f=="")f="0000";return sign*(w*10000+(f+0))}
NR==1{if($0!="evaluation_date\tseries_id\tobservation_date\tvintage_date\tvalue\tunits")bad(22);next}
{if(NF!=6)bad(23);if(length($1)!=10)bad(24);if(date=="")date=$1;else if(date!=$1)bad(25);x=fixed4($5);if($2=="DGS10"){if(hd||$6!="percent")bad(26);d=x;hd=1}else if($2=="NFCI"){if(hn||$6!="index")bad(27);n=x;hn=1}else if($2=="VIXCLS"){if(hv||$6!="index")bad(28);v=x;hv=1}else bad(29);rows++}
END{if(rows!=3||!hd||!hn||!hv)exit 30;rf=(d>=40000?1:0);nf=(n>=0?1:0);vf=(v>=200000?1:0);score=rf+nf+vf;if(score==0)lab="CALM";else if(score==1)lab="FRAGILE";else lab="STRESSED";print state,date,d,n,v,rf,nf,vf,score,lab}
AWK_EOF

test "$(sha "$STAGE/classification-contract.txt")" = "$EXPECTED_CONTRACT_SHA256" ||
    not_evaluated "CLASSIFICATION_CONTRACT_IDENTITY_MISMATCH"

test "$(sha "$AUTH/authority-1-c11.c")" = "$EXPECTED_AUTHORITY_1_SOURCE_SHA256" ||
    not_evaluated "AUTHORITY_1_IDENTITY_MISMATCH"

test "$(sha "$AUTH/authority-2-posix.awk")" = "$EXPECTED_AUTHORITY_2_SOURCE_SHA256" ||
    not_evaluated "AUTHORITY_2_IDENTITY_MISMATCH"

echo "CLASSIFICATION_CONTRACT=FROZEN"
echo "CLASSIFICATION_CONTRACT_SHA256=$EXPECTED_CONTRACT_SHA256"
echo "AUTHORITY_1_IDENTITY=FROZEN"
echo "AUTHORITY_1_SOURCE_SHA256=$EXPECTED_AUTHORITY_1_SOURCE_SHA256"
echo "AUTHORITY_2_IDENTITY=FROZEN"
echo "AUTHORITY_2_SOURCE_SHA256=$EXPECTED_AUTHORITY_2_SOURCE_SHA256"

section "2. COMPILE AUTHORITY 1 BEFORE EXECUTION GATE"

cc     -std=c11     -O2     -Wall     -Wextra     -Werror     "$AUTH/authority-1-c11.c"     -o "$AUTH/authority-1-c11" ||
    not_evaluated "TOOLCHAIN_DRIFT"

AUTHORITY_1_BINARY_SHA256="$(sha "$AUTH/authority-1-c11")"

echo "AUTHORITY_1_COMPILE=PASS"
echo "AUTHORITY_1_BINARY_SHA256=$AUTHORITY_1_BINARY_SHA256"

section "3. ONE-EXECUTION GATE"

cat > "$LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
SCRIPT_SHA256=$(sha "$0")
A0_EVIDENCE_MANIFEST_SHA256=$EXPECTED_A0_MANIFEST_SHA256
SNAPSHOT_A_SHA256=$EXPECTED_SNAPSHOT_A_SHA256
SNAPSHOT_B_SHA256=$EXPECTED_SNAPSHOT_B_SHA256
SNAPSHOT_C_SHA256=$EXPECTED_SNAPSHOT_C_SHA256
CLASSIFICATION_CONTRACT_SHA256=$EXPECTED_CONTRACT_SHA256
AUTHORITY_1_SOURCE_SHA256=$EXPECTED_AUTHORITY_1_SOURCE_SHA256
AUTHORITY_1_BINARY_SHA256=$AUTHORITY_1_BINARY_SHA256
AUTHORITY_2_SOURCE_SHA256=$EXPECTED_AUTHORITY_2_SOURCE_SHA256
EXECUTION_POLICY=ONE_EXECUTION
LOCK_CREATED_BEFORE_FIRST_CLASSIFICATION=YES
EOF

cp "$LOCK" "$EVIDENCE/execution-started.txt"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "EXECUTION_LOCK_SHA256=$(sha "$LOCK")"
echo "EXECUTION_GATE=PASS"

section "4. AUTHORITY 1 — C11"

HEADER="$(printf 'state\tevaluation_date\tdgs10_scaled\tnfci_scaled\tvixcls_scaled\trate_flag\tnfci_flag\tvix_flag\tscore\tclassification')"
printf '%s\n' "$HEADER" > "$RESULTS/authority-1.tsv"

for state in A B C
do
    "$AUTH/authority-1-c11" "$state" "$A0/snapshots/state-$state.tsv"         >> "$RESULTS/authority-1.tsv" ||
        not_evaluated "HARNESS_FAILURE"
done

test "$(wc -l < "$RESULTS/authority-1.tsv" | tr -d ' ')" = "4" ||
    not_evaluated "HARNESS_FAILURE"

echo "AUTHORITY_1_EXECUTION=PASS"
echo "AUTHORITY_1_RESULTS_SHA256=$(sha "$RESULTS/authority-1.tsv")"

section "5. AUTHORITY 2 — POSIX AWK"

printf '%s\n' "$HEADER" > "$RESULTS/authority-2.tsv"

for state in A B C
do
    awk -v state="$state" -f "$AUTH/authority-2-posix.awk"         "$A0/snapshots/state-$state.tsv"         >> "$RESULTS/authority-2.tsv" ||
        not_evaluated "HARNESS_FAILURE"
done

test "$(wc -l < "$RESULTS/authority-2.tsv" | tr -d ' ')" = "4" ||
    not_evaluated "HARNESS_FAILURE"

echo "AUTHORITY_2_EXECUTION=PASS"
echo "AUTHORITY_2_RESULTS_SHA256=$(sha "$RESULTS/authority-2.tsv")"

section "6. INDEPENDENT AUTHORITY EQUIVALENCE"

if ! cmp -s "$RESULTS/authority-1.tsv" "$RESULTS/authority-2.tsv"
then
    diff -u "$RESULTS/authority-1.tsv" "$RESULTS/authority-2.tsv"         > "$EVIDENCE/authority-divergence.diff" || true

    fail "AUTHORITY_IMPLEMENTATION_DIVERGENCE"
fi

cp "$RESULTS/authority-1.tsv" "$RESULTS/canonical-results.tsv"

echo "STATE_A_AUTHORITY_EQUIVALENCE=PASS"
echo "STATE_B_AUTHORITY_EQUIVALENCE=PASS"
echo "STATE_C_AUTHORITY_EQUIVALENCE=PASS"
echo "AUTHORITY_FEATURE_EQUIVALENCE=PASS"
echo "AUTHORITY_CLASSIFICATION_EQUIVALENCE=PASS"
echo "CANONICAL_RESULTS_SHA256=$(sha "$RESULTS/canonical-results.tsv")"

section "7. OBSERVED CLASSIFICATIONS"

cat "$RESULTS/canonical-results.tsv"

for state in A B C
do
    count="$(awk -F '\t' -v state="$state" 'NR > 1 && $1 == state { n++ } END { print n + 0 }' "$RESULTS/canonical-results.tsv")"
    test "$count" = "1" ||
        not_evaluated "HARNESS_FAILURE"
done

echo "STATE_A_CLASSIFICATION_RECORDED=PASS"
echo "STATE_B_CLASSIFICATION_RECORDED=PASS"
echo "STATE_C_CLASSIFICATION_RECORDED=PASS"

section "8. FREEZE A1 EVIDENCE"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
A0_EVIDENCE_MANIFEST_SHA256	$EXPECTED_A0_MANIFEST_SHA256
SNAPSHOT_A_SHA256	$EXPECTED_SNAPSHOT_A_SHA256
SNAPSHOT_B_SHA256	$EXPECTED_SNAPSHOT_B_SHA256
SNAPSHOT_C_SHA256	$EXPECTED_SNAPSHOT_C_SHA256
CLASSIFICATION_CONTRACT_SHA256	$EXPECTED_CONTRACT_SHA256
AUTHORITY_1_SOURCE_SHA256	$EXPECTED_AUTHORITY_1_SOURCE_SHA256
AUTHORITY_1_BINARY_SHA256	$AUTHORITY_1_BINARY_SHA256
AUTHORITY_2_SOURCE_SHA256	$EXPECTED_AUTHORITY_2_SOURCE_SHA256
AUTHORITY_1_RESULTS_SHA256	$(sha "$RESULTS/authority-1.tsv")
AUTHORITY_2_RESULTS_SHA256	$(sha "$RESULTS/authority-2.tsv")
CANONICAL_RESULTS_SHA256	$(sha "$RESULTS/canonical-results.tsv")
STATE_A_AUTHORITY_EQUIVALENCE	PASS
STATE_B_AUTHORITY_EQUIVALENCE	PASS
STATE_C_AUTHORITY_EQUIVALENCE	PASS
AUTHORITY_FEATURE_EQUIVALENCE	PASS
AUTHORITY_CLASSIFICATION_EQUIVALENCE	PASS
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

cp "$0" "$EVIDENCE/stage-a1-r1-script.sh"
cp "$STAGE/classification-contract.txt" "$EVIDENCE/classification-contract.txt"
cp "$AUTH/authority-1-c11.c" "$EVIDENCE/authority-1-c11.c"
cp "$AUTH/authority-1-c11" "$EVIDENCE/authority-1-c11.bin"
cp "$AUTH/authority-2-posix.awk" "$EVIDENCE/authority-2-posix.awk"
cp "$RESULTS/canonical-results.tsv" "$EVIDENCE/canonical-results.tsv"

(
    cd "$STAGE"
    find evidence results authorities         -type f         ! -name SHA256SUMS         ! -name SHA256SUMS.check         -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS > evidence/SHA256SUMS.check
) || not_evaluated "A1_EVIDENCE_INTEGRITY_FAILURE"

A1_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A1_EVIDENCE_INTEGRITY=PASS"
echo "A1_EVIDENCE_MANIFEST_SHA256=$A1_MANIFEST_SHA256"

section "9. A1 HOMOLOGATION"

echo "MARKET_REGIME_LINEAGE_001_STAGE_A1=PASS"
echo "A1_REVISION=$REVISION"
echo "CLASSIFICATION_CONTRACT=FROZEN"
echo "AUTHORITY_1_IDENTITY=FROZEN"
echo "AUTHORITY_2_IDENTITY=FROZEN"
echo "AUTHORITY_1_EXECUTION=PASS"
echo "AUTHORITY_2_EXECUTION=PASS"
echo "STATE_A_AUTHORITY_EQUIVALENCE=PASS"
echo "STATE_B_AUTHORITY_EQUIVALENCE=PASS"
echo "STATE_C_AUTHORITY_EQUIVALENCE=PASS"
echo "AUTHORITY_FEATURE_EQUIVALENCE=PASS"
echo "AUTHORITY_CLASSIFICATION_EQUIVALENCE=PASS"
echo "A1_EVIDENCE_INTEGRITY=PASS"
echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"
echo "NEXT_GATE=A2_YODA_DECISION_LINEAGE"

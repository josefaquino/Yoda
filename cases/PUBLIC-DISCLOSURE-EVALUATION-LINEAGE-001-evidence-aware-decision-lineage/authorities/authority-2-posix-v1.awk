BEGIN {
    FS = "\t"
    OFS = "\t"

    CONTRACT_ID = "PUBLIC-DISCLOSURE-EVALUATION-V1"
    EXPECTED_HEADER = "state\taccession\tform\tconcept\tunit\tstart\tend\tvalue_raw"
    OUT_HEADER = "contract\tconcept\tunit\tstart\tend\tvalue_a_raw\tvalue_b_raw\tcommon_scale\tdelta_coefficient\tbase_coefficient\tthreshold_basis_points\tclassification"

    input_error = 0
}

NR == 1 {
    if ($0 != EXPECTED_HEADER)
        input_error = 1
    next
}

NR == 2 {
    a_state = $1
    a_accession = $2
    a_form = $3
    a_concept = $4
    a_unit = $5
    a_start = $6
    a_end = $7
    a_raw = $8
    next
}

NR == 3 {
    b_state = $1
    b_accession = $2
    b_form = $3
    b_concept = $4
    b_unit = $5
    b_start = $6
    b_end = $7
    b_raw = $8
    next
}

NR > 3 {
    input_error = 1
}

function trimzero(s,    n) {
    n = length(s)

    while (n > 1 && substr(s, 1, 1) == "0") {
        s = substr(s, 2)
        n--
    }

    return s
}

function allzero(s,    i) {
    for (i = 1; i <= length(s); i++)
        if (substr(s, i, 1) != "0")
            return 0

    return 1
}

function parse_decimal(raw, which,    s, sign, dot, digits, scale, i, ch) {
    s = raw
    sign = 1
    dot = 0
    digits = ""
    scale = 0

    if (substr(s, 1, 1) == "+" || substr(s, 1, 1) == "-") {
        if (substr(s, 1, 1) == "-")
            sign = -1
        s = substr(s, 2)
    }

    if (s == "")
        return 0

    for (i = 1; i <= length(s); i++) {
        ch = substr(s, i, 1)

        if (ch == ".") {
            if (dot)
                return 0

            dot = 1
            continue
        }

        if (ch !~ /^[0-9]$/)
            return 0

        digits = digits ch

        if (dot)
            scale++
    }

    if (digits == "")
        return 0

    digits = trimzero(digits)

    if (allzero(digits))
        sign = 0

    if (which == "A") {
        pa_sign = sign
        pa_digits = digits
        pa_scale = scale
    } else {
        pb_sign = sign
        pb_digits = digits
        pb_scale = scale
    }

    return 1
}

function zeros(n,    s, i) {
    s = ""

    for (i = 0; i < n; i++)
        s = s "0"

    return s
}

function align_digits(digits, scale, common) {
    return trimzero(digits zeros(common - scale))
}

function cmpbig(a, b,    la, lb, i, da, db) {
    a = trimzero(a)
    b = trimzero(b)

    la = length(a)
    lb = length(b)

    if (la < lb)
        return -1

    if (la > lb)
        return 1

    for (i = 1; i <= la; i++) {
        da = substr(a, i, 1) + 0
        db = substr(b, i, 1) + 0

        if (da < db)
            return -1

        if (da > db)
            return 1
    }

    return 0
}

function reverse_string(s,    i, out) {
    out = ""

    for (i = length(s); i >= 1; i--)
        out = out substr(s, i, 1)

    return out
}

function addbig(a, b,    ia, ib, carry, out, da, db, sum) {
    ia = length(a)
    ib = length(b)
    carry = 0
    out = ""

    while (ia > 0 || ib > 0 || carry > 0) {
        da = 0
        db = 0

        if (ia > 0)
            da = substr(a, ia--, 1) + 0

        if (ib > 0)
            db = substr(b, ib--, 1) + 0

        sum = da + db + carry
        out = out (sum % 10)
        carry = int(sum / 10)
    }

    return trimzero(reverse_string(out))
}

function subbig(a, b,    ia, ib, borrow, out, da, db) {
    if (cmpbig(a, b) < 0)
        return "__ERROR__"

    ia = length(a)
    ib = length(b)
    borrow = 0
    out = ""

    while (ia > 0) {
        da = substr(a, ia--, 1) + 0
        db = 0

        if (ib > 0)
            db = substr(b, ib--, 1) + 0

        da -= borrow

        if (da < db) {
            da += 10
            borrow = 1
        } else {
            borrow = 0
        }

        out = out (da - db)
    }

    return trimzero(reverse_string(out))
}

function mulsmall(a, m,    i, carry, out, cur, d) {
    if (m == 0 || allzero(a))
        return "0"

    carry = 0
    out = ""

    for (i = length(a); i >= 1; i--) {
        d = substr(a, i, 1) + 0
        cur = d * m + carry
        out = out (cur % 10)
        carry = int(cur / 10)
    }

    while (carry > 0) {
        out = out (carry % 10)
        carry = int(carry / 10)
    }

    return trimzero(reverse_string(out))
}

END {
    if (NR != 3 ||
        input_error ||
        a_state != "A" ||
        b_state != "B" ||
        a_form != "10-K" ||
        b_form != "10-K/A") {
        exit 8
    }

    print OUT_HEADER

    if (a_concept != b_concept ||
        a_unit != b_unit ||
        a_start != b_start ||
        a_end != b_end ||
        a_unit != "USD") {
        print CONTRACT_ID, a_concept, a_unit, a_start, a_end, a_raw, b_raw, "-", "-", "-", "100", "NOT_COMPARABLE"
        exit 0
    }

    if (!parse_decimal(a_raw, "A") ||
        !parse_decimal(b_raw, "B")) {
        print CONTRACT_ID, a_concept, a_unit, a_start, a_end, a_raw, b_raw, "-", "-", "-", "100", "NOT_EVALUABLE"
        exit 0
    }

    common_scale = (pa_scale > pb_scale ? pa_scale : pb_scale)

    aa = align_digits(pa_digits, pa_scale, common_scale)
    bb = align_digits(pb_digits, pb_scale, common_scale)

    if (pa_sign == 0) {
        delta = bb
    } else if (pb_sign == 0) {
        delta = aa
    } else if (pa_sign == pb_sign) {
        if (cmpbig(aa, bb) >= 0)
            delta = subbig(aa, bb)
        else
            delta = subbig(bb, aa)
    } else {
        delta = addbig(aa, bb)
    }

    if (cmpbig(aa, bb) >= 0)
        base = aa
    else
        base = bb

    if (allzero(delta)) {
        classification = "UNCHANGED"
    } else {
        left = mulsmall(delta, 10000)
        right = mulsmall(base, 100)

        if (cmpbig(left, right) <= 0)
            classification = "CHANGED_WITHIN_THRESHOLD"
        else
            classification = "CHANGED_ABOVE_THRESHOLD"
    }

    print CONTRACT_ID, a_concept, a_unit, a_start, a_end, a_raw, b_raw, common_scale, delta, base, "100", classification
}

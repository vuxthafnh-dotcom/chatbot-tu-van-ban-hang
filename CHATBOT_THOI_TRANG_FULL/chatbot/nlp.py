import re
import unicodedata

def normalize_text(text):
    text = text.lower().strip()
    text = unicodedata.normalize("NFD", text)
    text = "".join(c for c in text if unicodedata.category(c) != "Mn")
    text = text.replace("đ", "d")
    return re.sub(r"\s+", " ", text)

def _price_to_amount(value, unit):
    value = float(value.replace(",", "."))
    if unit in ("k", "nghin", "ngan"):
        value *= 1000
    elif unit in ("trieu", "tr"):
        value *= 1_000_000
    return int(value)


def extract_price_filter(text):
    normalized = normalize_text(text)
    number = r"(\d+(?:[.,]\d+)?)"
    unit = r"\s*(trieu|tr|k|nghin|ngan)?"

    between = re.search(rf"\btu\s*{number}{unit}\s*(?:den|toi)\s*{number}{unit}", normalized)
    if between:
        lower_unit = between.group(2) or between.group(4) or ""
        upper_unit = between.group(4) or between.group(2) or ""
        return {
            "minimum": _price_to_amount(between.group(1), lower_unit),
            "maximum": _price_to_amount(between.group(3), upper_unit),
            "minimum_inclusive": True,
            "maximum_inclusive": True,
        }

    maximum = re.search(
        rf"\b(duoi|nho hon|thap hon|khong qua|toi da|tam gia|khoang)\s*{number}{unit}",
        normalized,
    )
    if maximum:
        inclusive = maximum.group(1) in ("khong qua", "toi da", "tam gia", "khoang")
        return {
            "minimum": None,
            "maximum": _price_to_amount(maximum.group(2), maximum.group(3) or ""),
            "minimum_inclusive": True,
            "maximum_inclusive": inclusive,
        }

    minimum = re.search(
        rf"\b(tren|hon|cao hon|tu|it nhat|toi thieu)\s*{number}{unit}",
        normalized,
    )
    if minimum:
        inclusive = minimum.group(1) in ("tu", "it nhat", "toi thieu")
        return {
            "minimum": _price_to_amount(minimum.group(2), minimum.group(3) or ""),
            "maximum": None,
            "minimum_inclusive": inclusive,
            "maximum_inclusive": True,
        }
    return None


def extract_price_limit(text):
    price_filter = extract_price_filter(text)
    if price_filter is None:
        return None
    return price_filter["maximum"]


def extract_keywords(text):
    t = normalize_text(text)
    r = {}
    if re.search(r"\b(nam|con trai|nam gioi)\b", t):
        r["gender"] = "Nam"
    elif re.search(r"\b(nu|con gai|nu gioi)\b", t):
        r["gender"] = "Nữ"

    if "ao khoac" in t:
        r["category_keyword"] = "ao khoac"
    elif "phu kien" in t or re.search(r"\b(mu|tui)\b", t):
        r["category_keyword"] = "phu kien"
    elif re.search(r"\bao\b", t):
        r["category_keyword"] = "ao"
    elif re.search(r"\bquan\b", t):
        r["category_keyword"] = "quan"
    elif re.search(r"\b(vay|dam)\b", t):
        r["category_keyword"] = "vay"

    color_words = {
        "den": ("đen", "Đen"),
        "trang": ("trắng", "Trắng"),
        "xanh": ("xanh", "Xanh"),
        "hong": ("hồng", "Hồng"),
        "xam": ("xám", "Xám"),
        "be": ("be", "Be"),
        "nau": ("nâu", "Nâu"),
        "do": ("đỏ", "Đỏ"),
    }
    for keyword, (spelling, color) in color_words.items():
        if re.search(rf"\b{re.escape(spelling)}\b", text, re.IGNORECASE) or re.search(
            rf"\b{keyword}\b", text, re.IGNORECASE
        ):
            r["color"] = color
            break

    m = re.search(r"\bsize\s*(s|m|l|xl|xxl|\d{2})\b", t)
    if m:
        r["size"] = m.group(1).upper()
    return r


def extract_product_requests(text):
    normalized = normalize_text(text)
    category_pattern = re.compile(
        r"\b(ao\s+khoac|giay\s+dep|phu\s+kien|giay|ao|quan|vay|dam|mu|tui)\b"
    )
    category_matches = list(category_pattern.finditer(normalized))
    category_map = {
        "ao": "ao",
        "ao khoac": "ao khoac",
        "giay dep": "giay",
        "giay": "giay",
        "quan": "quan",
        "vay": "vay",
        "dam": "vay",
        "phu kien": "phu kien",
        "mu": "phu kien",
        "tui": "phu kien",
    }
    colors = {
        "den": "Đen",
        "trang": "Trắng",
        "xanh": "Xanh",
        "hong": "Hồng",
        "xam": "Xám",
        "be": "Be",
        "nau": "Nâu",
        "do": "Đỏ",
    }

    requests = []
    for index, match in enumerate(category_matches):
        end = category_matches[index + 1].start() if index + 1 < len(category_matches) else len(normalized)
        segment = normalized[match.start():end]
        request = {"category_keyword": category_map[match.group(1)]}
        for keyword, color in colors.items():
            if re.search(rf"\b{keyword}\b", segment):
                request["color"] = color
                break
        requests.append(request)
    return requests

import argparse
import json
from dataclasses import asdict, dataclass
from pathlib import Path

import numpy as np
import pandas as pd


@dataclass
class TableProfile:
    name: str
    rows: int
    cols: int
    missing_cells: int
    missing_pct: float
    duplicate_rows: int


def _read_csv(path: Path) -> pd.DataFrame:
    return pd.read_csv(path)


def profile_table(df: pd.DataFrame, name: str) -> TableProfile:
    missing_cells = int(df.isna().sum().sum())
    total_cells = int(df.shape[0] * df.shape[1]) if df.shape[0] and df.shape[1] else 0
    missing_pct = float(round(missing_cells * 100.0 / total_cells, 4)) if total_cells else 0.0
    duplicate_rows = int(df.duplicated().sum())
    return TableProfile(
        name=name,
        rows=int(df.shape[0]),
        cols=int(df.shape[1]),
        missing_cells=missing_cells,
        missing_pct=missing_pct,
        duplicate_rows=duplicate_rows,
    )


def missing_by_column(df: pd.DataFrame) -> pd.DataFrame:
    missing = df.isna().sum()
    missing_pct = (missing / len(df) * 100.0).round(4) if len(df) else missing * 0.0
    out = pd.DataFrame({"missing_cnt": missing, "missing_pct": missing_pct})
    out = out[out["missing_cnt"] > 0].sort_values("missing_cnt", ascending=False)
    return out


def compute_gmv_compare(orders: pd.DataFrame, order_items: pd.DataFrame, order_payments: pd.DataFrame) -> dict:
    delivered_order_ids = orders.loc[orders["order_status"] == "delivered", "order_id"].dropna().unique()

    item_df = order_items[order_items["order_id"].isin(delivered_order_ids)].copy()
    item_df["item_amount"] = item_df["price"] + item_df["freight_value"]
    item_gmv = item_df.groupby("order_id", as_index=False)["item_amount"].sum().rename(columns={"item_amount": "item_gmv"})

    paid_gmv = (
        order_payments[order_payments["order_id"].isin(delivered_order_ids)]
        .groupby("order_id", as_index=False)["payment_value"]
        .sum()
        .rename(columns={"payment_value": "paid_gmv"})
    )

    gmv_compare = item_gmv.merge(paid_gmv, on="order_id", how="outer")
    gmv_compare["diff"] = gmv_compare["item_gmv"] - gmv_compare["paid_gmv"]

    item_total = float(gmv_compare["item_gmv"].sum(skipna=True))
    paid_total = float(gmv_compare["paid_gmv"].sum(skipna=True))
    diff_total = float(gmv_compare["diff"].sum(skipna=True))
    diff_pct_total = float(diff_total * 100.0 / item_total) if item_total else float("nan")

    diff_desc = gmv_compare["diff"].describe(percentiles=[0.01, 0.05, 0.5, 0.95, 0.99]).to_dict()
    diff_desc = {k: (float(v) if pd.notna(v) else None) for k, v in diff_desc.items()}

    return {
        "delivered_orders_cnt": int(len(delivered_order_ids)),
        "item_gmv_total": item_total,
        "paid_gmv_total": paid_total,
        "diff_total": diff_total,
        "diff_pct_total": diff_pct_total,
        "diff_describe": diff_desc,
    }


def compute_fk_consistency(orders: pd.DataFrame, order_items: pd.DataFrame, order_payments: pd.DataFrame, reviews: pd.DataFrame) -> dict:
    orders_ids = set(orders["order_id"].dropna().unique())
    items_ids = set(order_items["order_id"].dropna().unique())
    payments_ids = set(order_payments["order_id"].dropna().unique())
    reviews_ids = set(reviews["order_id"].dropna().unique())

    orphan_items = len(items_ids - orders_ids)
    orphan_payments = len(payments_ids - orders_ids)
    orphan_reviews = len(reviews_ids - orders_ids)

    return {
        "orders_order_id_nunique": int(orders["order_id"].nunique()),
        "order_items_order_id_nunique": int(order_items["order_id"].nunique()),
        "order_payments_order_id_nunique": int(order_payments["order_id"].nunique()),
        "reviews_order_id_nunique": int(reviews["order_id"].nunique()),
        "orphan_items_order_id_cnt": int(orphan_items),
        "orphan_payments_order_id_cnt": int(orphan_payments),
        "orphan_reviews_order_id_cnt": int(orphan_reviews),
    }


def compute_order_status(orders: pd.DataFrame) -> dict:
    vc = orders["order_status"].value_counts(dropna=False)
    delivered_cnt = int((orders["order_status"] == "delivered").sum())
    total = int(len(orders))
    delivered_pct = float(delivered_cnt * 100.0 / total) if total else float("nan")
    return {
        "status_counts": {str(k): int(v) for k, v in vc.items()},
        "delivered_cnt": delivered_cnt,
        "delivered_pct": delivered_pct,
        "total_orders_cnt": total,
    }


def render_markdown(
    table_profiles: list[TableProfile],
    missing_details: dict[str, pd.DataFrame],
    order_status: dict,
    fk_consistency: dict,
    gmv_compare: dict,
) -> str:
    lines: list[str] = []
    lines.append("# Python 数据质量检查报告")
    lines.append("")
    lines.append("## 1. 表概览")
    lines.append("")
    lines.append("| 表 | 行数 | 列数 | 缺失单元格数 | 缺失率(%) | 重复行数 |")
    lines.append("|---|---:|---:|---:|---:|---:|")
    for p in table_profiles:
        lines.append(
            f"| {p.name} | {p.rows:,} | {p.cols:,} | {p.missing_cells:,} | {p.missing_pct:.4f} | {p.duplicate_rows:,} |"
        )

    lines.append("")
    lines.append("## 2. 订单状态分布")
    lines.append("")
    lines.append(f"- 总订单数: `{order_status['total_orders_cnt']:,}`")
    lines.append(f"- 已送达订单数: `{order_status['delivered_cnt']:,}`（`{order_status['delivered_pct']:.2f}%`）")
    lines.append("")
    lines.append("| order_status | cnt |")
    lines.append("|---|---:|")
    for k, v in order_status["status_counts"].items():
        lines.append(f"| {k} | {v:,} |")

    lines.append("")
    lines.append("## 3. 主外键一致性")
    lines.append("")
    lines.append("| 指标 | 值 |")
    lines.append("|---|---:|")
    for k in [
        "orders_order_id_nunique",
        "order_items_order_id_nunique",
        "order_payments_order_id_nunique",
        "reviews_order_id_nunique",
        "orphan_items_order_id_cnt",
        "orphan_payments_order_id_cnt",
        "orphan_reviews_order_id_cnt",
    ]:
        lines.append(f"| {k} | {fk_consistency[k]:,} |")

    lines.append("")
    lines.append("## 4. GMV 口径一致性（item_gmv vs paid_gmv，仅 delivered）")
    lines.append("")
    lines.append("| 指标 | 值 |")
    lines.append("|---|---:|")
    lines.append(f"| delivered_orders_cnt | {gmv_compare['delivered_orders_cnt']:,} |")
    lines.append(f"| item_gmv_total | {gmv_compare['item_gmv_total']:,.2f} |")
    lines.append(f"| paid_gmv_total | {gmv_compare['paid_gmv_total']:,.2f} |")
    lines.append(f"| diff_total | {gmv_compare['diff_total']:,.2f} |")
    lines.append(f"| diff_pct_total | {gmv_compare['diff_pct_total']:.4f}% |")

    lines.append("")
    lines.append("diff 描述统计（单位同货币口径）:")
    lines.append("")
    lines.append("```json")
    lines.append(json.dumps(gmv_compare["diff_describe"], ensure_ascii=False, indent=2))
    lines.append("```")

    lines.append("")
    lines.append("## 5. 缺失值明细（按表 Top 列）")
    lines.append("")
    for table_name, df in missing_details.items():
        lines.append(f"### {table_name}")
        if df.empty:
            lines.append("- 无缺失值")
            lines.append("")
            continue
        top_df = df.head(15)
        lines.append("| column | missing_cnt | missing_pct |")
        lines.append("|---|---:|---:|")
        for col, row in top_df.iterrows():
            lines.append(f"| {col} | {int(row['missing_cnt']):,} | {float(row['missing_pct']):.4f}% |")
        lines.append("")

    lines.append("## 6. 结论")
    lines.append("")
    lines.append("- 数据完整性/一致性已完成自动化检查；如需进一步完善，可在此基础上加入字段级取值范围校验、时间戳逻辑校验等规则。")
    lines.append("- 当前报告可直接用于 GitHub 展示与面试答辩的‘数据质量’证据。")
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--archive-dir", default=str(Path(__file__).resolve().parent.parent / "archive"))
    parser.add_argument("--out-md", default=str(Path(__file__).resolve().parent.parent / "reports" / "python_data_quality_report.md"))
    parser.add_argument("--out-json", default=str(Path(__file__).resolve().parent.parent / "reports" / "python_data_quality_metrics.json"))
    args = parser.parse_args()

    archive_dir = Path(args.archive_dir)
    out_md = Path(args.out_md)
    out_json = Path(args.out_json)
    out_md.parent.mkdir(parents=True, exist_ok=True)

    required_files = {
        "orders": "olist_orders_dataset.csv",
        "order_items": "olist_order_items_dataset.csv",
        "order_payments": "olist_order_payments_dataset.csv",
        "customers": "olist_customers_dataset.csv",
        "reviews": "olist_order_reviews_dataset.csv",
        "products": "olist_products_dataset.csv",
    }

    missing_files = [fname for fname in required_files.values() if not (archive_dir / fname).exists()]
    if missing_files:
        raise FileNotFoundError(f"Missing CSV files under {archive_dir}: {missing_files}")

    orders = _read_csv(archive_dir / required_files["orders"])
    order_items = _read_csv(archive_dir / required_files["order_items"])
    order_payments = _read_csv(archive_dir / required_files["order_payments"])
    customers = _read_csv(archive_dir / required_files["customers"])
    reviews = _read_csv(archive_dir / required_files["reviews"])
    products = _read_csv(archive_dir / required_files["products"])

    table_profiles = [
        profile_table(orders, "orders"),
        profile_table(order_items, "order_items"),
        profile_table(order_payments, "order_payments"),
        profile_table(customers, "customers"),
        profile_table(reviews, "reviews"),
        profile_table(products, "products"),
    ]

    missing_details = {
        "orders": missing_by_column(orders),
        "order_items": missing_by_column(order_items),
        "order_payments": missing_by_column(order_payments),
        "customers": missing_by_column(customers),
        "reviews": missing_by_column(reviews),
        "products": missing_by_column(products),
    }

    order_status = compute_order_status(orders)
    fk_consistency = compute_fk_consistency(orders, order_items, order_payments, reviews)
    gmv_compare = compute_gmv_compare(orders, order_items, order_payments)

    report_md = render_markdown(table_profiles, missing_details, order_status, fk_consistency, gmv_compare)
    out_md.write_text(report_md, encoding="utf-8")

    metrics = {
        "table_profiles": [asdict(p) for p in table_profiles],
        "order_status": order_status,
        "fk_consistency": fk_consistency,
        "gmv_compare": gmv_compare,
        "generated_files": {
            "report_md": str(out_md),
            "metrics_json": str(out_json),
        },
    }
    out_json.write_text(json.dumps(metrics, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"Wrote: {out_md}")
    print(f"Wrote: {out_json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

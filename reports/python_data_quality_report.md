# Python 数据质量检查报告

## 1. 表概览

| 表 | 行数 | 列数 | 缺失单元格数 | 缺失率(%) | 重复行数 |
|---|---:|---:|---:|---:|---:|
| orders | 99,441 | 8 | 4,908 | 0.6169 | 0 |
| order_items | 112,650 | 7 | 0 | 0.0000 | 0 |
| order_payments | 103,886 | 5 | 0 | 0.0000 | 0 |
| customers | 99,441 | 5 | 0 | 0.0000 | 0 |
| reviews | 99,224 | 7 | 145,903 | 21.0063 | 0 |
| products | 32,951 | 9 | 2,448 | 0.8255 | 0 |

## 2. 订单状态分布

- 总订单数: `99,441`
- 已送达订单数: `96,478`（`97.02%`）

| order_status | cnt |
|---|---:|
| delivered | 96,478 |
| shipped | 1,107 |
| canceled | 625 |
| unavailable | 609 |
| invoiced | 314 |
| processing | 301 |
| created | 5 |
| approved | 2 |

## 3. 主外键一致性

| 指标 | 值 |
|---|---:|
| orders_order_id_nunique | 99,441 |
| order_items_order_id_nunique | 98,666 |
| order_payments_order_id_nunique | 99,440 |
| reviews_order_id_nunique | 98,673 |
| orphan_items_order_id_cnt | 0 |
| orphan_payments_order_id_cnt | 0 |
| orphan_reviews_order_id_cnt | 0 |

## 4. GMV 口径一致性（item_gmv vs paid_gmv，仅 delivered）

| 指标 | 值 |
|---|---:|
| delivered_orders_cnt | 96,478 |
| item_gmv_total | 15,419,773.75 |
| paid_gmv_total | 15,422,461.77 |
| diff_total | -2,831.48 |
| diff_pct_total | -0.0184% |

diff 描述统计（单位同货币口径）:

```json
{
  "count": 96477.0,
  "mean": -0.029348756698487303,
  "std": 1.1387058166343593,
  "min": -182.80999999999995,
  "1%": -5.684341886080802e-14,
  "5%": -1.4210854715202004e-14,
  "50%": 0.0,
  "95%": 1.4210854715202004e-14,
  "99%": 5.684341886080802e-14,
  "max": 51.620000000000005
}
```

## 5. 缺失值明细（按表 Top 列）

### orders
| column | missing_cnt | missing_pct |
|---|---:|---:|
| order_delivered_customer_date | 2,965 | 2.9817% |
| order_delivered_carrier_date | 1,783 | 1.7930% |
| order_approved_at | 160 | 0.1609% |

### order_items
- 无缺失值

### order_payments
- 无缺失值

### customers
- 无缺失值

### reviews
| column | missing_cnt | missing_pct |
|---|---:|---:|
| review_comment_title | 87,656 | 88.3415% |
| review_comment_message | 58,247 | 58.7025% |

### products
| column | missing_cnt | missing_pct |
|---|---:|---:|
| product_category_name | 610 | 1.8512% |
| product_name_lenght | 610 | 1.8512% |
| product_description_lenght | 610 | 1.8512% |
| product_photos_qty | 610 | 1.8512% |
| product_weight_g | 2 | 0.0061% |
| product_length_cm | 2 | 0.0061% |
| product_height_cm | 2 | 0.0061% |
| product_width_cm | 2 | 0.0061% |

## 6. 结论

- 数据完整性/一致性已完成自动化检查；如需进一步完善，可在此基础上加入字段级取值范围校验、时间戳逻辑校验等规则。
- 当前报告可直接用于 GitHub 展示与面试答辩的‘数据质量’证据。

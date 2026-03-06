# 指标口径说明（Olist 电商项目）

## 有效订单口径
- 仅统计 `order_status = 'delivered'` 的订单。

## GMV / 销售额
### item_gmv（口径 A，主口径）
- 定义：按订单商品明细汇总
- 计算：对同一 `order_id` 汇总 `sum(price + freight_value)`
- 适用场景：经营分析、品类/地区拆解、运费分析、履约分析（更贴运营分析）

### paid_gmv（口径 B，对账口径）
- 定义：按支付流水汇总
- 计算：对同一 `order_id` 汇总 `sum(payment_value)`
- 适用场景：回款/实付视角、与 item_gmv 做差异对账

## item_gmv 与 paid_gmv 可能不一致的常见原因
- 订单可能存在多次支付/分期/多支付方式（支付表多行，需要按订单汇总）。
- 促销/优惠券/折扣等导致实付金额与商品明细金额不同。
- 退款/取消/逆向流程在公开数据集中体现不完整，可能造成口径差异。
- 数据字段的四舍五入与单位精度差异。

## 客单价（AOV）
- 定义：`AOV = item_gmv / 订单量`
- 说明：AOV 基于订单粒度（非商品行粒度）。

## 差评率
- 定义：`bad_review_rate = review_score <= 2 的订单占比`
- 说明：评价为订单粒度，部分订单可能缺失评价。

## 准时率
- 定义：`ontime_rate = delivered_customer_date <= estimated_delivery_date 的订单占比`
- 说明：若任一日期缺失则准时标记为 NULL（在聚合时会影响平均值）。

# Starbucks TP: Business Insights and Interpretations

## Executive Summary
This document interprets the data generated from the `starbucks_dw_raw` Data Warehouse, specifically focusing on the operational bottlenecks during the "morning rush" (7:00 AM - 9:00 AM). The analysis aims to help operations managers optimize resources, reduce fulfillment times, and improve customer satisfaction.

---

## 1. Channel Performance During Morning Rush
**Business Question:** *What channel has the longest delays during the morning rush?*

**Data Results:**
| Channel | Avg Fulfillment Time (min) | Total Orders |
| :--- | :--- | :--- |
| Drive-Thru | 5.79 | 6875 |
| Mobile App | 4.50 | 10413 |
| Kiosk | 4.00 | 1799 |
| In-Store Cashier | 3.22 | 5384 |

**Interpretation:**
*   **The Bottleneck:** The **Drive-Thru** is the slowest channel by a significant margin, taking nearly 6 minutes on average per order during the morning peak.
*   **Volume vs. Speed:** Interestingly, the **Mobile App** handles the highest volume of orders (10,413) but maintains a relatively efficient fulfillment time (4.50 mins) compared to the Drive-Thru.
*   **Most Efficient:** In-Store Cashier is the fastest, highlighting that physical, standard line-ordering is highly optimized.

**Business Decision / Recommendation:**
*   **Resource Reallocation:** During the 7:00 AM - 9:00 AM window, reallocate staff or dedicated barista stations specifically to the Drive-Thru line to bring the 5.79-minute average down closer to the 4.50-minute Mobile App average.
*   **Process Review:** Investigate the Drive-Thru workflow. The delay might not just be drink preparation, but payment processing or handoff mechanics at the window.

---

## 2. Order Complexity vs. Delay Correlation
**Business Question:** *Does the complexity of the order (cart size and customizations) drive the delays in each channel?*

**Data Results (Morning Rush):**
| Channel | Avg Cart Size | Avg Customizations | Avg Fulfillment Time | Correlation (Customizations vs Delay) |
| :--- | :--- | :--- | :--- | :--- |
| Drive-Thru | 3.38 | 1.30 | 5.79 | 0.0047 (None) |
| In-Store Cashier | 3.40 | 1.29 | 3.22 | 0.0230 (Weak Positive) |
| Kiosk | 3.43 | 1.29 | 4.00 | -0.0152 (None) |
| Mobile App | 4.19 | 2.51 | 4.50 | -0.0102 (None) |

**Interpretation:**
*   **Complexity is NOT the problem:** Across all channels, the correlation coefficient between the number of customizations and fulfillment time is practically zero (ranging from -0.01 to 0.02). *This definitively rules out the hypothesis that highly customized drinks are the root cause of delays.*
*   **Mobile App Behavior:** Mobile App users order significantly more items (avg 4.19 vs ~3.40) and request almost double the customizations (2.51 avg), yet their orders are fulfilled faster than Drive-Thru orders with fewer customizations.

**Business Decision / Recommendation:**
*   **Process Review (CRITICAL):** Investigate the Drive-Thru workflow immediately. Because complexity and order size are not the cause of the delay, the bottleneck is heavily rooted in the Drive-Thru physical mechanics. **The delay might not just be drink preparation, but payment processing, system UI slowness, or handoff mechanics at the window.**
*   **Stop blaming the menu:** Barista training on complex drinks is likely already highly effective. Management must recognize the bottleneck is logistical, not prep-related.

---

## 3. Geographic Differences
**Business Question:** *Do location types or regions amplify these inefficiencies?*

**Top 5 Slowest Segments:**
| Location Type | Region | Avg Fulfillment Time | Avg Satisfaction |
| :--- | :--- | :--- | :--- |
| Rural | Northeast | 4.67 | 3.64 |
| Suburban | Southwest | 4.59 | 3.75 |
| Urban | West | 4.59 | 3.63 |
| Rural | Midwest | 4.58 | 3.65 |
| Rural | Southwest | 4.55 | 3.76 |

**Interpretation:**
*   **Variance is Low:** The fulfillment times across the top 10 slowest geographic segments are tightly clustered between 4.52 and 4.67 minutes.
*   **Rural Struggles:** Three of the top five slowest segments are Rural locations. Rural Northeast is the absolute slowest overall.
*   **Satisfaction Disconnect:** Interestingly, longer wait times do not always perfectly align with lower satisfaction. Suburban Southwest has higher delays (4.59) but higher satisfaction (3.75) compared to Urban West (4.59 delay, 3.63 satisfaction). Urban customers appear less tolerant of identical wait times.

**Business Decision / Recommendation:**
*   **Standardized Performance:** The tight variance suggests standard operating procedures (SOPs) are consistently applied Nationwide.
*   **Targeted Rural Audits:** Conduct operational audits in Rural locations (especially Northeast) to understand why they trail urban/suburban counterparts. It could be staffing levels, supply chain issues, or older store layouts.
*   **Urban Expectation Management:** Focus heavily on speed in Urban locations, as those customers penalize the brand more harshly for the exact same wait times.

---

## 4. Weekly Patterns
**Business Question:** *What days of the week are most critical for delays?*

**Data Results:**
| Day of Week | Avg Fulfillment Time | Total Orders |
| :--- | :--- | :--- |
| Thu | 4.56 | 14,214 |
| Sat | 4.55 | 14,443 |
| Tue | 4.55 | 14,385 |
| Fri | 4.55 | 14,277 |
| Mon | 4.54 | 14,386 |
| Sun | 4.53 | 14,175 |
| Wed | 4.53 | 14,120 |

**Interpretation:**
*   **Utter Consistency:** The delay is completely flat across the week. The worst day (Thursday, 4.56 min) is only 0.03 minutes slower than the best day (Wednesday, 4.53 min).
*   **Volume Predictability:** Order volume is also highly consistent, hovering around 14.1k - 14.4k orders every single day.

**Business Decision / Recommendation:**
*   **Static Scheduling is Viable:** Because demand and delays are uniform across the week, store managers do not need volatile, day-to-day shifting in labor models. A consistent weekly staffing structure is appropriate.
*   **Systemic Issue:** Because the delays don't fluctuate with specific high-stress days, the inefficiencies identified (namely, the Drive-Thru bottleneck) are systemic hardware/process flaws, not temporary staffing shortages on specific days.

---

## Final Conclusion
The analytical data definitively points to the **Drive-Thru** channel as the primary operational bottleneck. The delays are not caused by complex/large orders, nor are they wildly fluctuating by day of the week. Management should immediately focus capital and process engineering on improving throughput at the Drive-Thru window.

---

## 🛠️ Power BI Configuration Guide
If you want to manually recreate the 4 tables in Power BI Desktop to match the SQL outputs, select the unconfigured visual on the canvas and drag the following fields into the **Columns** well under the *Build a visual* pane:

### Visual 1: Channel Performance (Morning Rush)
1. **DimChannel** > `order_channel`
2. **FactOrders** > `Morning Rush Avg` (Measure)
3. **FactOrders** > `Total Orders` (Measure)
*(Note: Using the 'Morning Rush Avg' measure automatically filters to 07:00-09:00 hours just like the SQL).*

### Visual 2: Complexity vs Delay Correlation
1. **DimChannel** > `order_channel`
2. **FactOrders** > `cart_size` *(Set summarization to: Average)*
3. **FactOrders** > `num_customizations` *(Set summarization to: Average)*
4. **FactOrders** > `Avg Fulfillment Time` (Measure)
5. **FactOrders** > `Complexity vs Delay Correlation` (Measure)
6. **FactOrders** > `Total Orders` (Measure)

### Visual 3: Geographic Differences
1. **DimStore** > `store_location_type`
2. **DimStore** > `region`
3. **FactOrders** > `Avg Fulfillment Time` (Measure)
4. **FactOrders** > `Avg Satisfaction` (Measure)
*(Optional: Sort descending by Avg Fulfillment Time).*

### Visual 4: Weekly Fulfillment Patterns
1. **DimDate** > `day_of_week`
2. **FactOrders** > `Avg Fulfillment Time` (Measure)
3. **FactOrders** > `Total Orders` (Measure)

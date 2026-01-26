This is a more advanced request that moves from operational data (EHR) to **Analytical Data (OLAP)**. To analyze "Market Lift," we need a Star Schema design.

Market Lift is the difference between **Actual Sales** (influenced by marketing/campaigns) and **Baseline Sales** (what would have happened naturally).

### Part 1: The Data Warehouse Schema (Star Schema)

We will design a schema optimized for BI tools (Tableau, PowerBI, Looker).

#### 1. Fact Table: `Fact_Market_Sales`
This is the central table containing the daily performance metrics.
*   **FactID** (PK)
*   **DateKey** (FK to Dim_Date)
*   **LocationID** (FK to Dim_Location)
*   **ProductID** (FK to Dim_Product)
*   **CampaignID** (FK to Dim_Campaign) - *Null if no campaign active*
*   **Baseline_Units** (Integer) - *Predicted sales without marketing*
*   **Actual_Units** (Integer) - *Real sales numbers*
*   **Lift_Units** (Integer) - *Actual - Baseline*
*   **Revenue_USD** (Float)

#### 2. Dimension Tables
*   **Dim_Location**: Hierarchical data for USA, Mexico, Canada.
    *   *Columns:* LocationID, Country, State_Province, City, Region_Tier.
*   **Dim_Product**: The medicines.
    *   *Columns:* ProductID, BrandName, GenericName, TherapeuticArea (e.g., Diabetes, Cardio), Price_USD.
*   **Dim_Campaign**: The marketing interventions.
    *   *Columns:* CampaignID, CampaignName, Channel (TV, Digital, Rep), StartDate, EndDate, TargetCountry.

---

### Part 2: The Python Script

This script simulates **2 years** of data. It mathematically injects "Lift" (spikes in sales) during specific campaign windows so your dashboard will show obvious, actionable insights.

```python
import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta
from faker import Faker

fake = Faker()

# --- CONFIGURATION ---
START_DATE = datetime(2023, 1, 1)
DAYS = 730  # 2 Years
BASE_DAILY_SALES = 50  # Average units sold per day per location baseline

# --- 1. SETUP DIMENSIONS ---

# A. Locations (USA, Mexico, Canada)
# We focus on major states/provinces to keep data manageable but realistic
LOCATIONS = [
    {'Country': 'USA', 'State': 'California', 'City': 'Los Angeles'},
    {'Country': 'USA', 'State': 'New York', 'City': 'New York City'},
    {'Country': 'USA', 'State': 'Texas', 'City': 'Houston'},
    {'Country': 'USA', 'State': 'Florida', 'City': 'Miami'},
    {'Country': 'Canada', 'State': 'Ontario', 'City': 'Toronto'},
    {'Country': 'Canada', 'State': 'Quebec', 'City': 'Montreal'},
    {'Country': 'Canada', 'State': 'British Columbia', 'City': 'Vancouver'},
    {'Country': 'Mexico', 'State': 'CDMX', 'City': 'Mexico City'},
    {'Country': 'Mexico', 'State': 'Jalisco', 'City': 'Guadalajara'},
    {'Country': 'Mexico', 'State': 'Nuevo Leon', 'City': 'Monterrey'},
]

# B. Products (Therapeutic Areas)
PRODUCTS = [
    {'ID': 101, 'Brand': 'CardioFlow', 'Area': 'Cardiology', 'Price': 120.00},
    {'ID': 102, 'Brand': 'GlucoDown', 'Area': 'Diabetes', 'Price': 85.50},
    {'ID': 103, 'Brand': 'DermaClear', 'Area': 'Dermatology', 'Price': 45.00},
    {'ID': 104, 'Brand': 'NeuroCalm', 'Area': 'Neurology', 'Price': 210.00},
    {'ID': 105, 'Brand': 'ImmunoBoost', 'Area': 'Immunology', 'Price': 150.00},
]

# C. Campaigns (The Drivers of Lift)
# We define specific windows where sales should spike
CAMPAIGNS = [
    {
        'ID': 1, 'Name': 'USA SuperBowl Launch', 'Channel': 'TV', 
        'Start': datetime(2023, 2, 1), 'End': datetime(2023, 2, 28), 
        'TargetCountry': 'USA', 'TargetProduct': 101, 'LiftFactor': 1.8  # 80% Lift
    },
    {
        'ID': 2, 'Name': 'Canada Winter Wellness', 'Channel': 'Digital', 
        'Start': datetime(2023, 11, 1), 'End': datetime(2024, 1, 31), 
        'TargetCountry': 'Canada', 'TargetProduct': 105, 'LiftFactor': 1.4 # 40% Lift
    },
    {
        'ID': 3, 'Name': 'Mexico Cardio Push', 'Channel': 'Rep Visit', 
        'Start': datetime(2024, 5, 1), 'End': datetime(2024, 7, 30), 
        'TargetCountry': 'Mexico', 'TargetProduct': 101, 'LiftFactor': 1.5 # 50% Lift
    },
    {
        'ID': 4, 'Name': 'Global Diabetes Awareness', 'Channel': 'Social Media', 
        'Start': datetime(2024, 6, 1), 'End': datetime(2024, 6, 30), 
        'TargetCountry': 'All', 'TargetProduct': 102, 'LiftFactor': 1.3 # 30% Lift
    }
]

# --- HELPER FUNCTIONS ---

def get_seasonality(date_obj):
    """Adds a slight sine wave to simulate natural seasonal trends"""
    day_of_year = date_obj.timetuple().tm_yday
    # Peak in winter (end/start of year), trough in summer
    return 1 + 0.2 * np.cos((day_of_year - 1) * 2 * np.pi / 365)

def generate_data():
    fact_rows = []
    
    print("Generating Daily Sales Data for 3 Countries...")
    
    # Iterate through every day of the 2 years
    for d in range(DAYS):
        current_date = START_DATE + timedelta(days=d)
        seasonal_factor = get_seasonality(current_date)
        
        # Iterate through every location
        for loc_id, loc in enumerate(LOCATIONS, 1):
            
            # Iterate through every product
            for prod in PRODUCTS:
                
                # 1. Calculate Baseline (Natural Sales)
                # Random noise + Seasonality
                noise = random.uniform(0.8, 1.2)
                baseline = int(BASE_DAILY_SALES * seasonal_factor * noise)
                
                # 2. Check for Active Campaigns (The Lift)
                active_campaign_id = None
                lift_multiplier = 1.0
                
                for camp in CAMPAIGNS:
                    # Check Date Range
                    if camp['Start'] <= current_date <= camp['End']:
                        # Check Geography and Product Match
                        country_match = (camp['TargetCountry'] == 'All' or camp['TargetCountry'] == loc['Country'])
                        prod_match = (camp['TargetProduct'] == prod['ID'])
                        
                        if country_match and prod_match:
                            active_campaign_id = camp['ID']
                            lift_multiplier = camp['LiftFactor']
                            break # Assume only one major campaign per product per day
                
                # 3. Calculate Actuals
                # Actual = Baseline * Lift
                actual_units = int(baseline * lift_multiplier)
                
                # Add some randomness to the lift execution (not perfect every day)
                if active_campaign_id:
                    actual_units = int(actual_units * random.uniform(0.9, 1.1))

                revenue = round(actual_units * prod['Price'], 2)
                lift_units = actual_units - baseline
                
                fact_rows.append({
                    'Date': current_date.date(),
                    'Country': loc['Country'],
                    'State': loc['State'],
                    'City': loc['City'],
                    'BrandName': prod['Brand'],
                    'TherapeuticArea': prod['Area'],
                    'CampaignID': active_campaign_id if active_campaign_id else 0,
                    'Baseline_Units': baseline,
                    'Actual_Units': actual_units,
                    'Lift_Units': lift_units,
                    'Revenue_USD': revenue
                })
        
        if d % 100 == 0:
            print(f"Processed {d}/{DAYS} days...")

    return pd.DataFrame(fact_rows)

# --- EXECUTION ---

def main():
    # 1. Create Dimensions (For export reference)
    df_loc = pd.DataFrame(LOCATIONS)
    df_prod = pd.DataFrame(PRODUCTS)
    df_camp = pd.DataFrame(CAMPAIGNS)
    
    # Drop complex objects from Campaign DF for CSV export
    df_camp_clean = df_camp.drop(columns=['Start', 'End']).copy()
    df_camp_clean['StartDate'] = df_camp['Start'].dt.date
    df_camp_clean['EndDate'] = df_camp['End'].dt.date

    # 2. Generate Facts
    df_fact = generate_data()
    
    # 3. Export
    print("\nSaving Data...")
    df_fact.to_csv('Fact_Market_Sales.csv', index=False)
    df_camp_clean.to_csv('Dim_Campaigns.csv', index=False)
    df_prod.to_csv('Dim_Products.csv', index=False)
    
    print(f"\nSuccessfully generated {len(df_fact)} rows of market data.")
    print("Files created: Fact_Market_Sales.csv, Dim_Campaigns.csv, Dim_Products.csv")

if __name__ == "__main__":
    main()
```

### Part 3: The Insights for your Dashboard

Since you mentioned you want "Awesome Insights" for SQL tweaks and visualizations, here is exactly what you should build with this data:

#### Insight 1: The "Lift" Waterfall Chart
*   **Query logic:** Compare `Baseline_Units` vs `Actual_Units` where `CampaignID` is NOT NULL.
*   **The Story:** "Our 'USA SuperBowl Launch' campaign generated a **180% lift** in CardioFlow sales in February 2023 compared to the baseline forecast."
*   **Visual:** A dual-axis line chart. One dotted line for Baseline, one solid bold line for Actuals. The space between them is shaded green to represent "Lift."

#### Insight 2: Cross-Border Performance Heatmap
*   **Query logic:** `Sum(Lift_Units)` grouped by `Country` and `TherapeuticArea`.
*   **The Story:** "While the US responds well to TV campaigns for Cardiology, Mexico shows higher ROI on 'Rep Visits' (In-person sales) for the same drug."
*   **Visual:** A Map visual where the color intensity represents the Lift % (Actual / Baseline).

#### Insight 3: Campaign Efficiency (ROI)
*   **Query logic:** Calculate Total Revenue during campaign periods vs. Non-campaign periods.
*   **The Story:** "The 'Global Diabetes Awareness' campaign had a lower lift factor (1.3x) but because it ran in all 3 countries simultaneously, it generated the highest total net revenue."

#### SQL Query Example to try on this data:
Once you load this CSV into your SQL DB, run this to calculate the exact percentage lift per campaign:

```sql
SELECT 
    c.CampaignName,
    c.TargetCountry,
    SUM(f.Baseline_Units) as Total_Baseline,
    SUM(f.Actual_Units) as Total_Actual,
    (SUM(f.Actual_Units) - SUM(f.Baseline_Units)) as Net_Lift_Units,
    ROUND(((SUM(f.Actual_Units) * 1.0 / SUM(f.Baseline_Units)) - 1) * 100, 2) as Lift_Percentage
FROM Fact_Market_Sales f
JOIN Dim_Campaigns c ON f.CampaignID = c.ID
WHERE f.CampaignID != 0
GROUP BY c.CampaignName, c.TargetCountry
ORDER BY Lift_Percentage DESC;
```

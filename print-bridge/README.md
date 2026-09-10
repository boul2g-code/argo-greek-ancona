# ARGO K44 Print Bridge

Local zero-cost print bridge for the ARGO web order center and the Zucchetti K44 / C300H thermal printer.

## Printer
- Model: Zucchetti K44 / C300H
- Protocol: ESC/POS
- LAN target: `192.168.1.130`
- Default raw TCP port: `9100` (verify with the test below)

## Windows setup
1. Install Node.js 18+ on the always-on PC in the restaurant.
2. Copy this `print-bridge` folder to that PC.
3. Copy `.env.example` to `.env` and enter the ARGO admin email/password. Never commit `.env`.
4. Open PowerShell in this folder and run `npm start`.
5. On first start it creates a baseline and does NOT print old orders.
6. In ARGO Admin, use `ACCETTA & STAMPA` or `RISTAMPA`. A print_count change is detected and the ticket is sent by ESC/POS over LAN.

## Network test
From PowerShell on the restaurant PC:

```powershell
Test-NetConnection 192.168.1.130 -Port 9100
```

If `TcpTestSucceeded` is `True`, raw LAN printing is reachable. If false, print the K44 network/self-test page and use the port/IP shown there.

## Safety
This bridge only targets the kitchen printer IP. Do not point it to the fiscal printer. The ARGO admin password stays only in the local `.env` file and is not stored in GitHub.

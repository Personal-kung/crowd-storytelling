Project Scribe: Status Report & Technical Architecture

Date of Freeze: May 2024
System Type: UWB-Based Robotic Writing Ecosystem
Platform: All-ESP32-S3 (WROOM-1)

1. System Components

The system consists of three distinct hardware tiers communicating via ESP-NOW and UWB (Ultra-Wideband):

A. The Edge Pucks (Anchors x2)

Role: Stationary beacons for triangulation.

Form Factor: 32mm Circular PCB.

Core Logic: ESP32-S3-WROOM-1 + DWM3000 UWB Module.

Power: LiPo battery with TP4056 charger and DW01A protection.

Charging: Concentric copper rings on the bottom for orientation-independent Pogo Pin charging.

Status: Design finalized for ESP32 migration.

B. The Delta-Writer (The Executor)

Role: Mobile robot that performs the physical writing.

Form Factor: Triangular/Delta chassis with 3 N20 Omni-wheels.

Core Logic: ESP32-S3-WROOM-1.

Tracking: PMW3360DM-T2QU (High-end Optical Flow).

Actuation: 2x DRV8833 H-Bridges (driving 3 motors) + 1 Micro-servo (Pen lift).

Power Rail Snag Resolved: Requires a dedicated 1.8V LDO and Logic Level Shifting (3.3V <-> 1.8V) for the PMW3360 sensor.

C. The Base Station (The Hub)

Role: Charging dock and central server.

Form Factor: Rectangular slab with magnetic docking.

Power: USB-C (16-pin) with 5.1k resistors on CC pins.

Charging: Pogo Pin arrays outputting 5V to docked Pucks and Writer.

2. Technical Breakthroughs (Critical for Resume)

PMW3360DM-T2QU Integration (Per Datasheet C20612443)

Voltage: 1.8V - 2.1V (Requires 1.8V LDO).

Pins:

SPI: SCLK(10), MOSI(11), MISO(12), NCS(13).

Interrupts: MOTION(9), NRESET(7).

Power: VDD(4), VDDIO(5), VDDPIX(3 - Cap only), LED_P(15 - Anode).

Hardware Requirement: Must use LM19-LSI lens and maintain 2.4mm Z-height from paper.

Wiring & Logic

SPI Bus Sharing: DWM3000 and PMW3360 share the hardware SPI bus on ESP32-S3 (GPIO 11, 12, 13). They are separated by Chip Selects: UWB_CS (GPIO 10) and OPT_CS (GPIO 9).

Antenna Layout: Antenna areas for ESP32 and DWM3000 must NOT overlap. A "North-South" orientation on the PCB is required.

3. Pending Tasks

KiCad Routing: Complete the 1.8V rail routing on the Writer PCB.

Mechanical Alignment: Finalize the Edge.Cuts rectangular cutout (10.5mm) in the Writer PCB for the PMW3360 lens.

BOM Selection: Choose a TXB0104 level shifter and a 1.8V LDO (e.g., TLV70218) for the Writer.

# AI prompt for continuing
"I am resuming Project Scribe, a three-part robotic writing system (Base, Writer, Pucks). I have a technical status document and the PMW3360DM-T2QU datasheet. We left off at the Writer PCB layout, specifically integrating the 1.8V LDO and Logic Level Shifter for the optical flow sensor, and ensuring the DWM3000 and ESP32-S3 antennas do not overlap on the triangular chassis. Please review my status document and help me finalize the KiCad routing for the Writer."

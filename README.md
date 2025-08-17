# ⏰ FPGA 기반 Digital Clock & Sensor Integration

## 📌 프로젝트 개요
본 프로젝트는 **FPGA 기반 RTL 설계**를 통해 **디지털 시계(WATCH & STOPWATCH)**, **UART 통신**, **초음파 센서(HC-SR04)**, **온습도 센서(DHT11)**를 통합한 시스템을 구현한 최종 프로젝트입니다.  
Basys3 보드에서 동작하며, 각 모듈을 블록화하여 통합한 **Top Module**을 설계 및 검증하였습니다.

---

## 🛠️ 개발 환경
- **Board**: Xilinx Basys3  
- **Tool**: Vivado (Synthesis & Simulation), Verdi  
- **Language**: Verilog HDL  
- **Sensors**:  
  - 초음파 센서 HC-SR04  
  - 온습도 센서 DHT11  
- **통신 방식**: UART  

---

## 📂 시스템 구성
### 1. Top Module
- 전체 모듈을 통합한 최상위 블록  
- 명령 제어 일원화 및 기능 확장에 용이한 구조  

### 2. Watch & Stopwatch
- FPGA 내부 타이머 기반 시계 및 스톱워치 동작  
- UART를 통해 시간 정보 송신  

### 3. 초음파 센서 (HC-SR04)
- 거리 측정 기능 구현  
- Controller 블록 및 SR04 FSM 설계  
- 시뮬레이션 및 타이밍 검증 완료  
- [🎥 시연 영상](https://github.com/EunSeongL/Digital-Clock/blob/main/video/SR04.gif)  

### 4. 온습도 센서 (DHT11)
- FPGA로 온도·습도 데이터 수집  
- Data Path / Control Path 분리  
- FSM 기반 Controller 설계  
- 다양한 Timing 조건 검증  
- [🎥 시연 영상](https://github.com/EunSeongL/Digital-Clock/blob/main/video/DHT11.gif)

### 5. UART 통신
- 센서 및 시계 모듈의 데이터 송수신  
- 외부 디바이스와의 데이터 통합  

---

## ✅ 프로젝트 결과
- 모듈별 설계 및 시뮬레이션 검증 완료  
- UART 기반 통합 시스템 동작 확인  
- FPGA 보드에서 통합 시연 성공  
- 🎥 통합 시연 영상  

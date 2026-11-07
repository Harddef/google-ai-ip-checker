# 🔍 Google AI & Antigravity IP Checker

Утилита для быстрой проверки IP-адреса, прокси и VPN на доступность сервисов **Google Gemini** и **Google Antigravity (AGY)** прямо из консоли Windows.

![Windows](https://img.shields.io/badge/OS-Windows-blue?logo=windows)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 🎯 Зачем это нужно?

Google применяет разные правила гео-блокировок и проверок для разных продуктов:
- **Веб-версия Gemini** (`gemini.google.com`) может работать через прокси/VPN в браузере.
- **Antigravity IDE & Gemini API** (`cloudcode-pa.googleapis.com`, `generativelanguage.googleapis.com`) делают прямые API-запросы и часто возвращают `403 Forbidden` на датацентровых IP или неподдерживаемых локациях.

Этот скрипт мгновенно проверяет все критические эндпоинты и показывает, будут ли работать сервисы с текущего IP.

---

## ✨ Возможности

- 🌍 **Определение IP и локации**: отображает текущий внешний IP, страну, регион, город и провайдера (ASN).
- ⚡ **Раздельная проверка**:
  - **Gemini (Browser & API)**: Web UI, Gemini Core API, Google OAuth.
  - **Antigravity (AGY IDE)**: Antigravity Service, AGY backend, Auth tokens, Model API.
- 🚫 **Детект реального геоблока (HTTP 403)**: точно отличает живой эндпоинт от региональной блокировки Google.
- 🔄 **Интерактивный цикл (горячие клавиши)**:
  - `Enter` или `R` (включая русскую `К`) — моментальный повтор проверки (удобно при смене серверов в VPN).
  - `Q` (или русская `Й`) — быстрый выход.

---

## 🚀 Быстрый старт

1. Скачайте репозиторий или склонируйте его:
   ```bash
   git clone https://github.com/Harddef/google-ai-ip-checker.git
   cd google-ai-ip-checker
   ```
2. Запустите двойным кликом:
   ```cmd
   check_ip.bat
   ```

---

## 📋 Структура файлов

- `check_ip.bat` — запускает PowerShell-скрипт в обход ExecutionPolicy с поддержкой UTF-8.
- `check_ip.ps1` — основной скрипт проверок и интерфейса.
- `README.md` — документация.

---

## 📄 Лицензия

MIT License

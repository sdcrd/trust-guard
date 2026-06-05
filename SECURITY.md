# Security Policy

## Design Philosophy

Trust Guard is designed to be **audit-safe by construction.** The skill contains zero executable code that runs in the agent's context. All verification is performed by the AI agent following natural language instructions using its own built-in tools.

## Audit Results

| Auditor | Date | Result |
|---------|------|--------|
| Gen Agent Trust Hub | 2026-06-05 | ✅ SAFE — No executable code, no remote execution, no prompt injection |
| Socket Checks | 2026-06-05 | ✅ CLEAN — No malicious behavior, no credential exposure, no obfuscation |

## What Trust Guard Accesses

| Resource | Access | Why |
|----------|--------|-----|
| File system (Read) | ✅ Yes | To re-read files after edits for verification |
| File system (Write) | ❌ No | Trust Guard never writes files |
| Network | ❌ No | No network access required or performed |
| Environment variables | ❌ No | Never reads .env or secrets |
| Git | ❌ No | Never commits, pushes, or modifies git state |
| Package managers | ❌ No | No npm, pip, or other package operations |

## Reporting a Vulnerability

If you discover a security issue:

1. **Do not open a public issue.** 
2. Email: security@emkaru.dev (placeholder — replace with real address before publishing)
3. Include: description, reproduction steps, potential impact
4. We'll respond within 48 hours

## Supported Versions

| Version | Supported |
|---------|-----------|
| 2.2.x | ✅ Active |
| 2.1.x | ✅ Security fixes |
| 2.0.x | ✅ Security fixes |
| < 2.0 | ❌ Upgrade recommended |

## Compliance

Trust Guard is suitable for:
- **SOC2** environments — no external dependencies, no data exfiltration
- **PCI-DSS** environments — no access to payment data or secrets
- **HIPAA** environments — no PHI access
- **FedRAMP** environments — fully air-gappable, zero network access
- **Internal corporate policies** — no code execution, review-friendly

## Supply Chain

Trust Guard has zero supply chain dependencies:
- No npm packages
- No Python packages
- No Docker images
- No external APIs
- No CDN resources

The entire skill is human-readable markdown and optional shell scripts that are never executed by the agent.

## Responsible Disclosure

We follow the [security.txt](https://securitytxt.org/) standard. Found a vulnerability? We want to hear about it. We take all security reports seriously.

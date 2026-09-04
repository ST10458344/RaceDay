# RaceDay – Part 1: System Planning and Database

RaceDay is a web-based event management platform for the South African road running, walking, and cycling community. This repository contains  planning deliverables only 

## User Roles

| Role | Capabilities |
|---|---|
| **Organiser** | Full CRUD on events and categories; record participant results; view all enrolments across the system. |
| **Participant** | Register an account; browse events; enrol in a category; view own enrolments and personal results. |

## Repository Structure

```
RaceDay/
├── docs/
│   ├── erd.png                  # Entity Relationship Diagram (export from erd.mmd)
│   ├── erd.mmd                  # Mermaid source for the ERD
│   ├── api-endpoints.md         # Full REST API endpoint plan
│   └── raceday-schema.sql       # SQL Server CREATE + seed script
├── .github/workflows/
│   └── part1-validation.yml     # CI/CD structure validation
└── README.md
```

### 2. Run the SQL script in SSMS

1. Open **SQL Server Management Studio (SSMS)** on your Cloudlabs VM.
2. Connect to the local SQL Server instance (usually `(localdb)\MSSQLLocalDB` or `localhost`).
3. Open `docs/raceday-schema.sql`.
4. Press **F5** (Execute). You should see: `RaceDay database created and seeded successfully.`
5. Verify in Object Explorer: database **RaceDay** with 7 tables and sample data.

### 3. Export the ERD as PNG

 **draw.io / diagrams.net**:

1. Open [https://app.diagrams.net](https://app.diagrams.net).
2. Recreate the diagram using the entity list in `docs/erd.mmd`.
3. Export as PNG to `docs/erd.png`.

## CI/CD Build Status

<!-- Replace this with your screenshot after the first green build -->
![CI/CD Green Build](docs/ci-green-build.png)

## Video Presentation

<!-- Replace with your unlisted YouTube link -->
YouTube (unlisted): https://youtu.be/your-video-id-here

Your video should cover:

- ERD design decisions (entities, PKs, FKs, cardinality)
- API endpoint plan walkthrough
- Live SSMS execution of `raceday-schema.sql`
- Clear voiceover

## Database Design Summary

| Entity | Purpose |
|---|---|
| **Roles** | Organiser and Participant role definitions |
| **Users** | All system users (both roles) |
| **UserRoles** | Many-to-many link between Users and Roles |
| **Events** | Race/walk/cycle events created by organisers |
| **Categories** | Distance/age divisions within an event |
| **Enrolments** | Participant registration in a category |
| **Results** | Finish times and positions for enrolments |

The ERD and SQL script are intentionally aligned. `UserRoles` resolves the many-to-many relationship between Users and Roles.

## Part 1 Checklist

- [ ] ERD saved as `docs/erd.png` (or PDF)
- [ ] API endpoint plan in `docs/api-endpoints.md`
- [ ] SQL script runs cleanly in SSMS
- [ ] README updated with YouTube link and CI screenshot
- [ ] Minimum 20 meaningful commits pushed to GitHub
- [ ] GitHub Actions shows green build

## License

Academic project – The Independent Institute of Education (2026).

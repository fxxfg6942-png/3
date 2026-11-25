# Query Suggestion Web Service

Autocomplete for Wikipedia titles. Type in the search box and get 10 suggestions:
your recent searches first, then the most popular titles that start with what you typed.

ASP.NET Core Web API (.NET 10) · jQuery page · hybrid trie in memory (no database) · data in AWS S3 · hosted on AWS EC2 behind Nginx.

**Build phase 1 of 6: Project setup.** The app starts and shows a placeholder page.

## Folders

```text
query-suggestion/
├── QuerySuggestion.Api/     The whole application
│   ├── Properties/          Local run settings (port 5299)
│   └── wwwroot/             Placeholder page
├── docs/
│   ├── Setup_and_Deployment_Guide.docx   Step by step: AWS, data, EC2
│   ├── diagrams/            Flowcharts, sequence and class diagrams
│   └── planning/            Planning and design documents
```

## Commands (run inside QuerySuggestion.Api)

| Command | What it does |
|---|---|
| `dotnet build` | Builds the app. Warnings are errors; every public class and method needs a `/// <summary>` |
| `dotnet run` | Starts the app at http://localhost:5299 |

## Getting started

Follow `docs/Setup_and_Deployment_Guide.docx` from Part 0.

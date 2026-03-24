# Terminology Server (SNOMED CT on InterSystems IRIS)

## Overview

This project implements a terminology server based on **InterSystems IRIS for Health**, focused initially on **SNOMED CT**, with a scalable architecture designed to support additional terminologies (e.g., LOINC, ICD-10) in the future.

The system provides:

- RF2 ingestion pipeline (base + extensions)
- Terminology normalization and enrichment
- Hierarchical reasoning (closure table)
- REST API for terminology access
- Integration with InterSystems Productions (BS/BP/BO pattern)

---

## Architecture

The solution follows a layered architecture:

REST API (CSP.REST)
↓
Business Service (Gateway)
↓
Business Operation (Repository)
↓
Database (Terminology tables)


### Components

- **API Layer**
  - `Terminology.Production.API.SnomedApi`
- **Gateway Service**
  - `Terminology.Production.BS.SnomedGatewayService`
- **Repository (BO)**
  - `Terminology.Production.BO.SnomedRepositoryOperation`
- **Processing (BP)**
  - `Terminology.Production.BP.SnomedRf2Load`

---

## Data Model

### Core SNOMED Tables

- `Terminology_Snomed.Concept`
- `Terminology_Snomed.Description`
- `Terminology_Snomed.Relationship`
- `Terminology_Snomed.RefsetMember`

### Derived / Optimized Tables

- `Terminology_Snomed.PreferredTerm`
- `Terminology_Snomed.IsaClosure`
- `Terminology_Snomed.PreferredTermStage`
- `Terminology_Snomed.LanguageRefSetConfig`

---

## RF2 Loader

### Features

- Loads SNOMED CT **Snapshot** distributions
- Supports:
  - International base
  - National extensions (e.g., Spanish)
- Merges multiple sources into a single `ReleaseId`
- Avoids data loss using `pClearRelease`

### Performance Optimizations

- Prepared statement reuse
- Row-based batched inserts
- Avoidance of large parameter stacks
- File discovery independent of folder structure

---

## PreferredTerm Builder

### Purpose

Creates a normalized table for fast lookup of preferred terms.

### Key Design

- Uses `Description + RefsetMember + Concept`
- Language refset is **explicitly configured**
- Two-phase process:
  1. Populate `PreferredTermStage`
  2. Insert into `PreferredTerm`

### Optimizations

- Eliminated nested queries
- Eliminated correlated subqueries
- Avoided joins during final insert
- Logging at each step

---

## ISA Closure Builder

### Purpose

Precomputes the SNOMED hierarchy for fast navigation.

### Features

- Supports:
  - `inferred` and `stated` views
- Uses memoization for performance
- Stores:
  - Ancestor
  - Descendant
  - Depth

---

## REST API

### Base Path

/snomed

### Endpoints

#### Search

GET /snomed/search

#### Concept

GET /snomed/concepts/{conceptId}

#### Hierarchy

GET /snomed/concepts/{conceptId}/children
GET /snomed/concepts/{conceptId}/descendants
GET /snomed/concepts/{conceptId}/ancestors

#### Descriptions

GET /snomed/concepts/{conceptId}/descriptions

#### Subsumption

GET /snomed/subsumes/{codeA}/{codeB}

#### Refsets

GET /snomed/refsets
GET /snomed/refsets/{refsetId}/members

#### Validation

GET /snomed/validate-code


---

## Query Design

All repository queries:

- Use dynamic SQL construction (`whereList`, `joinList`)
- Avoid unnecessary joins
- Use indexes (`%FIND` for search)
- Apply filters only when parameters are present

---

## Testing

A test suite was implemented covering:

- Search functionality
- Concept lookup
- Hierarchical navigation
- Subsumption logic
- Refset retrieval
- Code validation

### Validation Types

- Functional correctness
- Data consistency
- Pagination
- Edge cases

---

## Performance Improvements

Major optimizations applied:

- Removed Python loops in builders
- Replaced row-by-row SQL execution
- Eliminated heavy joins in final stages
- Introduced staging tables
- Reused prepared statements
- Avoided large argument stacks

---

## Current Capabilities

The system now supports:

- Full SNOMED ingestion (base + extension)
- Fast term lookup
- Hierarchical reasoning
- Subsumption checks
- Refset navigation
- Code validation

---

## Next Steps

Recommended future work:

### Functional

- Semantic search (vector embeddings)
- Refset expansion logic
- Concept relationships API

### Standardization

- FHIR Terminology API:
  - `$lookup`
  - `$subsumes`
  - `$validate-code`
  - `$expand`

### Generalization

- Introduce `Terminology.Core` model
- Add support for:
  - LOINC
  - ICD-10
  - RxNorm

---

## Summary

This project implements a production-ready SNOMED CT terminology server with:

- Efficient RF2 ingestion
- Optimized data model
- Scalable architecture
- Fully functional REST API

It is designed to evolve into a multi-terminology, FHIR-compliant terminology platform.
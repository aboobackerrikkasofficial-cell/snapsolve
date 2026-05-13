# Architecture Documentation

## Core Philosophy
SnapSolve is built on the principles of **Clean Architecture** and **Unidirectional Data Flow**. The goal is to decouple the UI from the AI logic and hardware interfaces.

## Project Structure
- `lib/ai/`: Contains the intelligence layer.
  - `providers/`: Model-specific implementations (Gemini, Groq, etc.).
  - `consensus_engine.dart`: Orchestrates multi-model verification.
- `lib/services/`: Low-level system services.
  - `api_service.dart`: The primary orchestrator for analysis requests.
  - `security_utils.dart`: Encryption, rate limiting, and hashing.
- `lib/providers/`: State management (using Provider).
  - `analysis_provider.dart`: Manages the lifecycle of an analysis task.
- `lib/models/`: Domain entities.
  - `analysis_result.dart`: The final diagnostic object.
  - `problem_context.dart`: Metadata about the screenshot.
- `lib/widgets/`: Atomic UI components.
  - `smart_error_view.dart`: Dynamic rendering of diagnostic data.

## Data Flow
1. **Input**: User selects a screenshot or provides text.
2. **Contextualization**: `ProblemContext` is created with metadata.
3. **Orchestration**: `ApiService` runs local heuristics.
4. **Analysis**: `ConsensusEngine` queries multiple LLMs in parallel.
5. **Consensus**: Engine verifies and merges results into a single `AiResponse`.
6. **Result**: UI renders the `AnalysisResult` with actionable steps.

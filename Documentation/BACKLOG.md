# quarrel — backlog

Untriaged signal. One file per item under `Backlog/`; this index is generated
(`canon-index index`) and never hand-edited.

<!-- BEGIN GENERATED INDEX — do not edit by hand; run `canon-index` -->
_Next id: `BL-0022` (generated; capture new items with this id)._
### Now
| BL | Title | Type | Sev | Big idea | Status | ↗ |
|----|-------|------|-----|----------|--------|---|
| BL-0002 | The shipper exits when its file is missing and keys offsets by path, so rotation loses its place | Bug | Major | — | New | [·](Backlog/BL-0002-argus-exits-on-a-missing-file-and-keys-offsets-by-path.md) |
| BL-0019 | quarrel has no demo consumer, so there is nothing to send telemetry to or look at, and no controllable test collector | Process-idea | — | — | Triaged | [·](Backlog/BL-0019-quarrel-has-no-demo-consumer-to-receive-and-show-its-telemetry.md) |
### Next
| BL | Title | Type | Sev | Big idea | Status | ↗ |
|----|-------|------|-----|----------|--------|---|
| BL-0003 | Decide the probe's I/O model, async (Tokio) or a synchronous poll loop over non-blocking sockets | Standard-gap | — | — | New | [·](Backlog/BL-0003-decide-the-probes-io-model-async-or-a-synchronous-poll-loop.md) |
| BL-0006 | TLS to the collector is not FIPS-validated, so quarrel cannot yet serve regulated environments that require it | Standard-gap | — | — | Triaged | [·](Backlog/BL-0006-tls-to-the-collector-is-not-fips-validated.md) |
| BL-0007 | quarrel-shipper's OTLP output contract is not yet documented for consumers who need to build a receiver or adapter | Doc-debt | — | — | Triaged | [·](Backlog/BL-0007-the-otlp-output-contract-is-not-yet-documented-for-consumers.md) |
| BL-0016 | Choose quarrel-ping's network-ownership datasets (prefix to AS, AS to organisation, exchange points) and check their licences | Standard-gap | — | — | Triaged | [·](Backlog/BL-0016-choose-the-network-ownership-datasets-and-check-their-licences.md) |
| BL-0020 | No documented recipe shows quarrel feeding a stock OpenTelemetry Collector and open-source dashboards | Doc-debt | — | — | Triaged | [·](Backlog/BL-0020-no-documented-recipe-for-quarrel-with-a-stock-opentelemetry-stack.md) |
### Someday
| BL | Title | Type | Sev | Big idea | Status | ↗ |
|----|-------|------|-----|----------|--------|---|
| BL-0004 | quarrel has no network probe yet, only the shipper | Process-idea | — | — | Triaged | [·](Backlog/BL-0004-quarrel-has-no-network-probe-yet.md) |
| BL-0008 | Optional lesson: Huffman coding and a small inflate (DEFLATE) decoder, kept outside the shipping path | Process-idea | — | — | Triaged | [·](Backlog/BL-0008-lesson-huffman-coding-and-an-inflate-decoder.md) |
| BL-0009 | Optional lesson (quarrel-ping): clocks — what "now" costs and means on each OS | Process-idea | — | — | Triaged | [·](Backlog/BL-0009-lesson-what-now-costs-and-means.md) |
| BL-0010 | Optional lesson (quarrel-ping): latency statistics — summarising latency without lying | Process-idea | — | — | Triaged | [·](Backlog/BL-0010-lesson-summarising-latency-without-lying.md) |
| BL-0011 | Optional lesson (quarrel-ping): coordinated omission — the classic latency-measurement trap | Process-idea | — | — | Triaged | [·](Backlog/BL-0011-lesson-the-coordinated-omission-trap.md) |
| BL-0012 | Optional lesson (quarrel-ping): loss confidence — how many probes it takes to claim a loss rate | Process-idea | — | — | Triaged | [·](Backlog/BL-0012-lesson-how-many-probes-a-loss-rate-needs.md) |
| BL-0013 | Optional lesson (quarrel-ping): path simulation — traceroute without sockets | Process-idea | — | — | Triaged | [·](Backlog/BL-0013-lesson-traceroute-without-sockets.md) |
| BL-0014 | Optional lesson (quarrel-ping): clock synchronisation — one-way delay and why it is hard | Process-idea | — | — | Triaged | [·](Backlog/BL-0014-lesson-one-way-delay-and-why-it-is-hard.md) |
| BL-0015 | Optional lesson (quarrel-ping): latency anatomy — where the milliseconds come from | Process-idea | — | — | Triaged | [·](Backlog/BL-0015-lesson-where-the-milliseconds-come-from.md) |
| BL-0017 | quarrel-ping has no standalone terminal UI for watching a path live (planned, future) | Process-idea | — | — | Triaged | [·](Backlog/BL-0017-quarrel-ping-standalone-tui-mode.md) |
| BL-0018 | Possible enhancement: native Windows and macOS desktop clients for quarrel-ping | Process-idea | — | — | New | [·](Backlog/BL-0018-possible-native-windows-and-macos-clients-for-quarrel-ping.md) |
| BL-0021 | Optional lesson (quarrel-ping): change-point detection — finding where a step change begins | Process-idea | — | — | Triaged | [·](Backlog/BL-0021-lesson-finding-where-a-step-change-begins.md) |
### Closed (collapsed)
| BL | Title | Type | Sev | Big idea | Status | ↗ |
|----|-------|------|-----|----------|--------|---|
| BL-0001 | The extraction carried 85 release tags from the previous repository into quarrel | Process-idea | — | — | Closed | [·](Backlog/BL-0001-services-release-tags-carried-into-quarrel.md) |
| BL-0005 | Move argus into the workspace as quarrel-shipper, and rename argus everywhere it names the live code | Tech-debt | — | — | Closed | [·](Backlog/BL-0005-move-argus-into-the-workspace-as-quarrel-shipper.md) |
<!-- END GENERATED INDEX -->

"""Cluster and test environment configuration."""
import os
from pathlib import Path


# resolve CARDANO_NODE_SOCKET_PATH
os.environ["CARDANO_NODE_SOCKET_PATH"] = str(
    Path(os.environ["CARDANO_NODE_SOCKET_PATH"]).expanduser().resolve()
)


CLUSTER_ERA = os.environ.get("CLUSTER_ERA") or ""
if CLUSTER_ERA not in ("", "mary", "alonzo"):
    raise RuntimeError(f"Invalid CLUSTER_ERA: {CLUSTER_ERA}")

TX_ERA = os.environ.get("TX_ERA") or ""
if TX_ERA not in ("", "shelley", "allegra", "mary", "alonzo"):
    raise RuntimeError(f"Invalid TX_ERA: {TX_ERA}")

CLUSTERS_COUNT = os.environ.get("CLUSTERS_COUNT") or 0

BOOTSTRAP_DIR = os.environ.get("BOOTSTRAP_DIR") or ""

NOPOOLS = bool(os.environ.get("NOPOOLS"))

HAS_DBSYNC = bool(os.environ.get("DBSYNC_REPO"))
if HAS_DBSYNC:
    DBSYNC_BIN = (
        Path(os.environ["DBSYNC_REPO"]) / "db-sync-node" / "bin" / "cardano-db-sync"
    ).resolve()
else:
    DBSYNC_BIN = Path("nonexistent")

HAS_SMASH = HAS_DBSYNC and bool(os.environ.get("USE_SMASH"))
if HAS_SMASH:
    SMASH_BIN = (
        Path(os.environ["DBSYNC_REPO"]) / "cardano-smash-server_master"
    ).resolve()
else:
    SMASH_BIN = Path("nonexistent")

DONT_OVERWRITE_OUTFILES = bool(os.environ.get("DONT_OVERWRITE_OUTFILES"))

# determine what scripts to use to start the cluster
SCRIPTS_DIRNAME = os.environ.get("SCRIPTS_DIRNAME") or ""
if SCRIPTS_DIRNAME:
    pass
elif BOOTSTRAP_DIR and NOPOOLS:
    SCRIPTS_DIRNAME = "testnets_nopools"
elif BOOTSTRAP_DIR:
    SCRIPTS_DIRNAME = "testnets"
else:
    SCRIPTS_DIRNAME = CLUSTER_ERA or "alonzo"

SCRIPTS_DIR = Path(__file__).parent.parent / "cluster_scripts" / SCRIPTS_DIRNAME

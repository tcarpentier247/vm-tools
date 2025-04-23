#!/usr/bin/env python3

import re
import yaml
import argparse
from collections import defaultdict

# Motif d'exclusion (grep -Ev)
exclude_pattern = re.compile(
    r"(lxc|kvm|pez|cname|labzone|envoy|^c\d+svc|^c\d+nas|^zone|^flex|^failover|"
    r"^sol|collector|igw|vip |malab|haproxy|infra-|proxy|squid|prome|grafan|"
    r"freenas|truenas|relay|registry|keycloa|^#)"
)

def build_clusters(input_path, output_path, filters=None):
    clusters = defaultdict(list)

    with open(input_path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or exclude_pattern.search(line):
                continue
            parts = line.split()
            if len(parts) < 3:
                continue
            node, cluster, tier = parts[:3]
            if tier in {"11", "12", "13"}:
                clusters[cluster].append(node)

    # Appliquer le filtre si précisé
    if filters:
        clusters = {k: v for k, v in clusters.items() if k in filters}

    # Tri numérique des clés
    sorted_clusters = dict(sorted(clusters.items(), key=lambda x: int(x[0])))

    # Écriture YAML
    with open(output_path, "w") as f:
        yaml.dump({"clusters": sorted_clusters}, f, default_flow_style=False, sort_keys=False)

    print(f"✅ Fichier YAML généré : {output_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Génère un fichier YAML clusters à partir de vdc.nodes.")
    parser.add_argument("-i", "--input", required=True, help="Chemin vers le fichier vdc.nodes")
    parser.add_argument("-o", "--output", required=True, help="Chemin vers le fichier YAML de sortie")
    parser.add_argument("-f", "--filter", help="Liste de clés (clusters) à inclure, séparées par des virgules", default="")
    args = parser.parse_args()

    filter_list = args.filter.split(",") if args.filter else None

    build_clusters(args.input, args.output, filter_list)


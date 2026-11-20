#module load python/3.14.3
#pip install pygenomeviz --user

from pygenomeviz import GenomeViz
from pygenomeviz.parser import Gff
from pygenomeviz.utils import is_pseudo_feature
import matplotlib.pyplot as plt

gff_file = "/dfs7/jje/jenyuw/Non_melanogaster/EGAPX_annotation/MV25_egapx/complete.genomic.gff"
target_regions = {
    "h1tg000005l": (8000000, 38000000),
    "h1tg000002l": (47000000, 50000000),
    "h1tg000004l": (10000000, 12500000),
}

region_image_files = []

for seqid, region in target_regions.items():
    gv = GenomeViz(
        fig_track_height=1,
        track_align_type="center",
        feature_track_ratio=0.5,
    )
    gv.set_scale_xticks(labelsize=10)

    gff = Gff(gff_file, target_seqid=seqid)
    features = gff.extract_features(
        feature_type=["rRNA", "pseudogene"],
        target_range=region,
    )
    track = gv.add_feature_track(seqid, (region,))
    track.add_sublabel(size=10, color="grey")
    segment = track.segments[0]
    for feature in features:
        color = "grey" if feature.type == "pseudogene" or is_pseudo_feature(feature) else "blue"
        segment.add_features(
            feature,
            plotstyle="bigarrow",
            arrow_shaft_ratio=0.7,
            label_type="gene",
            color=color,
        )

    image_file = f"{seqid}_{region[0]}_{region[1]}.png"
    gv.savefig(image_file)
    region_image_files.append(image_file)

fig, axes = plt.subplots(len(region_image_files), 1, figsize=(15, 3 * len(region_image_files)))
for axis, image_file in zip(axes, region_image_files):
    axis.imshow(plt.imread(image_file))
    axis.axis("off")
fig.tight_layout()
fig.savefig("gff_regions_combined.png", dpi=300, bbox_inches="tight")
plt.close(fig)
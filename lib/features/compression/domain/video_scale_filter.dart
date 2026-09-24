String videoScaleFilter(int maxDimension) =>
    'scale=$maxDimension:$maxDimension:'
    'force_original_aspect_ratio=decrease:force_divisible_by=2';

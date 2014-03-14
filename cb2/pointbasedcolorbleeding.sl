surface pointbasedcolorbleeding
(
  string filename = "", sides = "front";
  float clampbleeding = 1, sortbleeding = 1,
	maxdist = 1e15, falloff = 0, falloffmode = 0,
	samplebase = 0, bias = 0,
	maxsolidangle = 0.05, maxvariation = 0, intensity = 1.0;
)
{
  normal Nn = normalize(N);
  color irr = 0;
  float occ = 0;

  irr = intensity * indirectdiffuse(P, Nn, 0, "pointbased", 1, "filename", filename,
                        "hitsides", sides,
                        "clamp", clampbleeding,
                        "sortbleeding", sortbleeding,
                        "maxdist", maxdist, "falloff", falloff,
                        "falloffmode", falloffmode,
                        "samplebase", samplebase, "bias", bias,
                        "maxsolidangle", maxsolidangle,
                        "maxvariation", maxvariation,
                        "distribution", "uniform");

  Ci = Os * Cs * irr;
  Oi = Os;
}

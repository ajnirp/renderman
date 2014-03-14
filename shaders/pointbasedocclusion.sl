#include "normals.h"

surface
pointbasedocclusion (string filename = "";
                     string hitsides = "both";
                     float maxdist = 1e15, falloff = 0, falloffmode = 0,
                     samplebase = 0, bias = 0.01,
                     clampocclusion = 1, maxsolidangle = 0.05,
                     maxvariation = 0)
{
  normal Ns = shadingnormal(N);
  float occ;

  occ = occlusion(P, Ns, 0, "pointbased", 1, "filename", filename,
                  "hitsides", hitsides, "maxdist", maxdist,
                  "falloff", falloff, "falloffmode", falloffmode,
                  "samplebase", samplebase, "bias", bias,
                  "clamp", clampocclusion,
                  "maxsolidangle", maxsolidangle,
                  "maxvariation", maxvariation);

  Ci = (1 - occ) * Os;
  Oi = Os;
}

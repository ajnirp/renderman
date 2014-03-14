surface texturesurf
(
  string filename = "",
         sides = "front",
         hitsides = "both",
         texturename = "grass.tex";
  float clampbleeding = 1,
        sortbleeding = 1,
	      maxdist = 1e15,
        falloff = 0,
        falloffmode = 0,
        samplebase = 0,
        bias = 0,
        maxsolidangle = 0.05,
        maxvariation = 0,
        intensity = 1.0,
        clampocclusion = 1,
        Kc=.5, // caustics coefficient
        Ka=1, // ambient coefficient
        Kd=.5 // diffuse coefficient
)
{
  normal Nn = normalize(N);
  color irr = 0;
  float occ = 0;

  irr = 4 * intensity * indirectdiffuse(P, Nn, 0, "pointbased", 1, "filename", filename,
                        "hitsides", sides,
                        "clamp", clampbleeding,
                        "sortbleeding", sortbleeding,
                        "maxdist", maxdist, "falloff", falloff,
                        "falloffmode", falloffmode,
                        "samplebase", samplebase, "bias", bias,
                        "maxsolidangle", maxsolidangle,
                        "maxvariation", maxvariation,
                        "distribution", "uniform");

  float opac = float texture (texturename, s, t);
  color Ct = color texture (texturename, s, t) + (1-opac)*Cs; // texture original color

  // calling the point based variant of the occlusion function
  occ = 0.8 * occlusion(P, Nn, 0, "pointbased", 1, "filename", filename,
                  "hitsides", hitsides, "maxdist", maxdist,
                  "falloff", falloff, "falloffmode", falloffmode,
                  "samplebase", samplebase, "bias", bias,
                  "clamp", clampocclusion,
                  "maxsolidangle", maxsolidangle,
                  "maxvariation", maxvariation);

  Ci = Ct * irr * (1 - occ);
  Ci += Ct * (Kd * diffuse(Nn) + Ka * ambient());
  Ci += Kc * photonmap("causticrefl.cpm", P, N, "estimator", 400); // add photon mapping for caustics
  Ci *= Os;
  Oi = Os;
}
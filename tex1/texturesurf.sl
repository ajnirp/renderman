surface
texturesurf
(
    float Ka=1,
          Kd=1,
          Kr=.5,
          Kt=.5,
          Kc=.3,
          Kcb=4.5,
          eta=1.5;
    string texturename = "grass.tex";
)
{
  normal Nn = normalize(N);
  vector In = normalize(I);

  normal v = faceforward(Nn, In);
  v = normalize(v);
  color local_illumination = Ka * ambient() + Kd * diffuse(Nn);

  color Ct;
  float opac = float texture (texturename, s, t);
  Ct = color texture (texturename, s, t) + (1-opac)*Cs;

  Ci += Ct * 0.5 * local_illumination;
  Ci += Kcb * indirectdiffuse(P, Nn, 1000); // color bleeding
  Ci += Kc * photonmap("causticrefl.cpm", P, N, "estimator", 400); // caustics
  float occ = occlusion(P, v, 2000, "maxvariation", 0.01, "falloff", 2, "maxdist", 1, "maxpixeldist", 7); // soft shadows
  Ci *= Os * 0.4 * (1 - occ);
  Oi = Os;
}

surface
diffsurf
(
    float Ka=1,
          Kd=3,
          Kr=.5,
          Kt=.5,
          Kc=.3,
          eta=1.5
)
{
  normal Nn = normalize(N);
  vector In = normalize(I);

  normal v = faceforward(Nn, In);
  v = normalize(v);
  color local_illumination = Ka * ambient() + Kd * diffuse(Nn);


  Ci += Cs * 0.75 * local_illumination;
  Ci += 4.5 * indirectdiffuse(P, Nn, 1000); // color bleeding
  Ci += Kc * photonmap("causticrefl.cpm", P, N, "estimator", 400); // caustics
  float occ = occlusion(P, v, 2000, "maxvariation", 0.02, "falloff", 2, "maxdist", 15, "maxpixeldist", 12); // soft shadows
  Ci *= Os * 0.4 * (1 - occ);
  Oi = Os;
}

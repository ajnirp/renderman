surface
diffsurf
(
    float Ka=1,
          Kd=1,
          Kr=.5,
          Kt=.5,
          Kc=1,
          eta=1.5
)
{
  normal Nn = normalize(N);
  color local_illumination = Ka * ambient() + Kd * diffuse(Nn);

  Ci += Cs * local_illumination;
  // Ci += indirectdiffuse(P, Nn, 1000); // ray-tracing-style color bleeding, not used here since we're doing point based
  Ci += Kc * photonmap("causticrefl.cpm", P, N, "estimator", 400);
  /*Ci += caustic(P, Nn);*/
  Ci *= Os;
  Oi = Os;
}

/*
surface
diffsurf
(
    float Ka=1,
          Kd=1,
          Kr=.5,
          Kt=.2,
          roughness=.1,
          eta=1.5;
    color specularcolor=1
)
{
  normal Nn = normalize(N);
  vector In = normalize(I);

  uniform float d = 0;
  rayinfo("depth", d);

  if (d < 3) {
    if (Nn.In < 0) {
      vector reflected_ray = reflect(In,Nn);
      Ci += Kr * trace(P, reflected_ray);
    }
    vector refracted_ray = refract(In, Nn, eta);
    Ci += Kt * trace(P, refracted_ray);
  }

  vector v = faceforward(Nn, In);
  v = normalize(v);
  color local_illumination = Ka * ambient() + Kd * diffuse(Nn);

  Ci += Cs * local_illumination;
  Ci *= Os;
  Oi = Os;
}
*/
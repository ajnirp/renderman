// eta = index of refraction
surface
specsurf
(
    float Ka=1,
          Ks=1,
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

  normal v = faceforward(Nn, In);
  v = normalize(v);
  color local_illumination = Ka * ambient() + Kd * diffuse(Nn) + Ks * specular(v, -In, roughness);

  Ci += Cs * local_illumination;
  Ci *= Os;
  Oi = Os;
}
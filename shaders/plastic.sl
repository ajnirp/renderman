surface plastic
(
  float Ks = 0.5;
  float Kd = 0.5;
  float Ka = 1, roughness = 0.1;
  color specularcolor = 1
)
{
    normal Nf;
    vector V;

    Nf = faceforward( normalize(N), I );
    V = -normalize(I);

    Oi = Os;
    Ci = Os * ( Cs * color(1, 0, 0) * (Ka*ambient() + Kd*diffuse(Nf)) +
	 	specularcolor * Ks * specular(Nf,V,roughness) );
}

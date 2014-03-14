surface
bake_areas( uniform string filename = "", displaychannels = "" )
{
  normal Nn = normalize(N);
  float a, opacity;

  a = area(P, "dicing"); // micropolygon area
  opacity = 0.333333 * (Os[0] + Os[1] + Os[2]); // average opacity
  a *= opacity; // reduce area if non-opaque

  if (a > 0)
    bake3d(filename, displaychannels, P, Nn, "interpolate", 1, "_area", a);

  Ci = Cs * Os;
  Oi = Os;
}

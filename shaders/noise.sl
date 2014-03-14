surface noise
(
  float frequency = 5;
  float amplitude = 1;
)
{
  point Pobject = transform("object", P);
  
  Oi = Os;
  Ci = Os * Cs * noise(Pobject * frequency) * 1;
}
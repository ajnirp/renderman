surface texturemap
(
  string file = "textures/grid.tex"
)
{
  Oi = Os;
  Ci = Os * Cs * texture(file);
}
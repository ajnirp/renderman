light
pointlight(
    float intensity = 2;
    color lightcolor = 1;
    point from = point "shader" (0,0,0);	/* light position */
)
{
    illuminate( from )
	Cl = intensity * lightcolor / L.L;
}

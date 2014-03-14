light
pointlight_shadows
(
    float intensity = 1;
    color lightcolor = 1;
    point from = point "shader" (0,0,0);	/* light position */
)
{
    illuminate(from)
    {
		Cl = intensity * transmission(Ps,from) * lightcolor / L.L;
	}
    
}

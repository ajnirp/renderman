light
pointlight_shadows
(
    float intensity = 1,
          samples = 256;
    color lightcolor = 1;
    point from = point "shader" (0,0,0);	/* light position */
    output float __nonspecular = 1;
)
{
	// float attenutation = shadow("raytrace", Ps, "samples", 5);
    illuminate(from)
    {
		Cl = intensity * lightcolor / L.L;
		Cl *= transmission(Ps, from);
		// Cl *= (1 - attenutation);
	}
}

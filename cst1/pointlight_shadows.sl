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
		Cl = intensity * lightcolor / L.L;
		/*printf("%f", transmission(Ps,from));*/
		color black_color = 0;
		if (transmission(Ps,from) == black_color) {
			/*printf("black mil gaya\n");*/
			Cl = black_color;
		}
	}
    
}

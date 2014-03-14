# color bleeding

all: rrt

rrt:
	shader specsurf.sl
	shader diffsurf.sl
	shader pointlight_shadows.sl
	prman ptc.rib
	prman rrt.rib
    
clean:
	rm -f rrt.tif
	rm -f causticrefl.cpm
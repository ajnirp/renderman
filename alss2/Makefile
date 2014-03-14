# color bleeding

all: rrt

rrt: shaders cpm ptc
	prman rrt.rib

cpm: cpm.rib
	prman cpm.rib

shaders:
	shader *.sl

ptc: ptc.rib
	prman ptc.rib
    
clean:
	rm -f *.tif
	rm -f *.slo
	rm -f *.ptc
	rm -f *.cpm

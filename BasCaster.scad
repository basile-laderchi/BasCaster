hub_bolt_size = "M3";
hub_bolt_thickness = 2;
hub_height = 2;
hub_side_thickness = 2;
hub_ring_thickness = 1;
hub_extra_length = 0;
hub_extra_height = 1;
axle_diameter = 3;
pin_radius = 2;
wheel_diameter = 20;
small_sphere_diameter = 3;
small_sphere_y = 0.1;
inner_padding = 0.3;
print_mode = false;

/*
 *
 * BasCaster v0.4
 *
 * by Basile Laderchi
 *
 * Licensed under Creative Commons Attribution-ShareAlike 3.0 Unported http://creativecommons.org/licenses/by-sa/3.0/
 *
 * v 0.4, 31 July 2013 : Using pins v2 library for connecting the 2 hemispheres to the main axle. Added pin_radius parameter
 * v 0.3, 30 July 2013 : Added print_mode parameter (rotates the hub ready for printing)
 * v 0.2, 29 July 2013 : First gamma print (by jinx) failed http://www.youtube.com/watch?v=NPs9qu7P9ec (Y braket broke upon cleaning of support and caster wheel stuck on the inner axle). Changed default hub_side_thickness from 1mm to 2mm and hub_extra_height from 0mm to 1mm
 * v 0.1, 26 July 2013 : Initial release
 *
 */

basCaster(hub_bolt_size, hub_bolt_thickness, hub_height, hub_side_thickness, hub_ring_thickness, hub_extra_length, hub_extra_height, axle_diameter, pin_radius, wheel_diameter, small_sphere_diameter, small_sphere_y, inner_padding, print_mode, $fn=100);

use <Libs.scad> // http://www.thingiverse.com/thing:6021
use <pins.scad> // http://www.thingiverse.com/thing:10541

module basCaster(hub_bolt_size, hub_bolt_thickness, hub_height, hub_side_thickness, hub_ring_thickness, hub_extra_length, hub_extra_height, axle_diameter, pin_radius, wheel_diameter, small_sphere_diameter, small_sphere_y, inner_padding, print_mode) {
	print_padding = 1;

	hub_length = wheel_diameter + (hub_side_thickness * 2) + hub_extra_length;
	hub_width = wheel_diameter;
	hub_ring_inner_diameter = axle_diameter + inner_padding;
	hub_ring_outer_diameter = hub_ring_inner_diameter + hub_ring_thickness;
	axle_length = hub_length + inner_padding * 2;
	hub_ring_inner_radius = (axle_diameter + inner_padding) / 2;
	hub_z_offset = hub_ring_thickness + hub_ring_inner_radius;
	hub_side_height = wheel_diameter / 2 - hub_z_offset + hub_extra_height;

	print_translate_x = print_mode ? (axle_length + wheel_diameter) / 2 + print_padding : 0;
	print_translate_z = print_mode ? hub_height + hub_side_height + hub_ring_thickness + hub_ring_inner_diameter / 2: 0;
	print_rotate_x = print_mode ? 180 : 0;

	translate([-print_translate_x / 2, 0, print_translate_z]) {
		rotate([print_rotate_x, 0, 0]) {
			hub([hub_length, hub_width, hub_height], hub_bolt_size, hub_bolt_thickness, hub_ring_inner_diameter, hub_side_height, hub_ring_thickness, hub_side_thickness);
		}
		axle(axle_diameter, axle_length, pin_radius);
	}
	if (!print_mode) {
		spherical_wheel(axle_diameter, pin_radius, wheel_diameter, small_sphere_diameter, small_sphere_y, inner_padding);
	} else {
		translate([print_translate_x / 2, 0, 0]) {
			spherical_two_halves_wheel(axle_diameter, pin_radius, wheel_diameter, small_sphere_diameter, small_sphere_y, inner_padding);
		}
	}
}

module hub(size, hole_size, hole_side_spacing, axle_diameter, hub_side_height, ring_thickness, ring_height) {
	side_hub_x = ((len(size) == 3)? size[0] : size);
	side1_x = (side_hub_x - ring_height) / 2;
	side2_x = (ring_height - side_hub_x) / 2;
	axle_radius = axle_diameter / 2;
	hub_z = hub_side_height + ring_thickness + axle_radius;

	translate([0, 0, hub_z]) {
		union() {
			hub_upper_plate(size, hole_size, hole_side_spacing);
			hub_side_plate(size, axle_diameter, hub_side_height, ring_thickness, ring_height, side1_x);
			hub_side_plate(size, axle_diameter, hub_side_height, ring_thickness, ring_height, side2_x);
		}
	}
}

module hub_upper_plate(size, hole_size, hole_side_spacing) {
	padding = 0.1;

	hub_x = ((len(size) == 3)? size[0] : size);
	hub_y = ((len(size) == 3)? size[1] : size);
	hub_z = ((len(size) == 3)? size[2] : size);
	hub_half_y = hub_y / 2;
	hub_half_z = hub_z / 2;
	hole_radius = tableEntry(hole_size, "studDiameter") / 2;
	hole_y = hub_half_y + hole_radius + hole_side_spacing;
	hole_z = - hub_half_z - padding;

	translate([0, 0, hub_half_z]) {
		difference() {
			hull() {
				cube([hub_x, hub_y, hub_z], center=true);
				translate([0, hole_y, 0]) {
					cylinder(r=hole_radius + hole_side_spacing, h=hub_z, center=true);
				}
				translate([0, -hole_y, 0]) {
					cylinder(r=hole_radius + hole_side_spacing, h=hub_z, center=true);
				}
			}
			if (tableRow(hole_size) != -1) {
				translate([0, hole_y, hole_z]) {
					capBolt(hole_size, hub_z + padding * 2);
				}
				translate([0, -hole_y, hole_z]) {
					capBolt(hole_size, hub_z + padding * 2);
				}
			}
		}
	}
}

module hub_side_plate(size, axle_diameter, hub_side_height, ring_thickness, ring_height, x) {
	padding = 0.1;

	side_z = 2;
	half_side_z = side_z / 2;

	hub_y = ((len(size) == 3)? size[1] : size);
	axle_radius = axle_diameter / 2;
	outer_ring_radius = axle_radius + ring_thickness;

	difference() {
		hull() {
			translate([x, 0, -half_side_z]) {
				cube([ring_height, hub_y, side_z], center=true);
			}
			translate([x, 0, - outer_ring_radius - hub_side_height]) {
				rotate([0, 90, 0]) {
					cylinder(r=outer_ring_radius, h=ring_height, center=true);
				}
			}
		}
		translate([x, 0, - outer_ring_radius - hub_side_height]) {
			rotate([0, 90, 0]) {
				cylinder(r=axle_radius, h=ring_height + padding, center=true);
			}
		}
	}
}

module axle(axle_diameter, axle_length, pin_radius) {
	axle_stopper_padding = 2;

	axle_radius = axle_diameter / 2;
	axle_stopped_radius = axle_radius + axle_stopper_padding;
	axle_stopper_height = 1;

	union() {
		rotate([0, 270, 0]) {
			cylinder(r=axle_radius, h=axle_length, center=true);
		}
		translate([(axle_length + axle_stopper_height) / 2, 0, 0]) {
			rotate([0, 90, 0]) {
				cylinder(r=axle_stopped_radius, h=axle_stopper_height, center=true);
			}
		}
		translate([-(axle_length + axle_stopper_height) / 2, 0, 0]) {
			rotate([0, 90, 0]) {
				cylinder(r=axle_stopped_radius, h=axle_stopper_height, center=true);
			}
		}
		inner_axle(axle_diameter, pin_radius);
	}
}

module inner_axle(axle_diameter, pin_radius) {
	pin_length = axle_diameter / 2 + 4.5;

	union() {
		rotate([90, 0, 0]) {
			pin(pin_length, pin_radius);
		}
		rotate([-90, 0, 0]) {
			pin(pin_length, pin_radius);
		}
	}
}

module inner_axle_cutout(axle_diameter, pin_radius) {
	pin_length = axle_diameter / 2 + 4.5;

	union() {
		rotate([90, 0, 0]) {
			pinhole(pin_length, pin_radius, tight=false);
		}
		rotate([-90, 0, 0]) {
			pinhole(pin_length, pin_radius, tight=false);
		}
	}
}

module spherical_two_halves_wheel(axle_diameter, pin_radius, wheel_diameter, small_sphere_diameter, small_sphere_y, inner_padding) {
	padding = 0.5;

	sphere_y = wheel_diameter / 2 + padding;

	translate([0, sphere_y, 0])	{
		spherical_half_wheel(axle_diameter, pin_radius, wheel_diameter, small_sphere_diameter, small_sphere_y, inner_padding);
	}
	translate([0, -sphere_y, 0])	{
		spherical_half_wheel(axle_diameter, pin_radius, wheel_diameter, small_sphere_diameter, small_sphere_y, inner_padding);
	}
}

module spherical_half_wheel(axle_diameter, pin_radius, wheel_diameter, small_sphere_diameter, small_sphere_y, inner_padding) {
	padding = 0.1;

	sphere_y = axle_diameter + inner_padding * 2;
	cube_size = wheel_diameter + padding;

	rotate([-90, 0, 0]) {
		translate([0, sphere_y / 2, 0]) {
			difference() {
				spherical_wheel(axle_diameter, pin_radius, wheel_diameter, small_sphere_diameter, small_sphere_y, inner_padding);
				translate([-cube_size / 2, 0, -cube_size / 2]) {
					cube(cube_size);
				}
			}
		}
	}
}

module spherical_wheel(axle_diameter, pin_radius, wheel_diameter, small_sphere_diameter, small_sphere_y, inner_padding) {
	wheel_radius = wheel_diameter / 2;
	small_sphere_radius = small_sphere_diameter / 2;
	small_sphere_y = wheel_radius - small_sphere_radius + small_sphere_y;
	cube_xz = (wheel_radius + inner_padding) * 2;
	cube_y = axle_diameter + inner_padding * 2;

	difference() {
		sphere(r=wheel_radius);
		translate([- cube_xz / 2, - cube_y / 2, - cube_xz / 2]) {
			cube([cube_xz, cube_y, cube_xz]);
		}
		translate([0, wheel_radius - small_sphere_radius + inner_padding, 0]) {
			sphere(r=small_sphere_radius + inner_padding);
		}
		translate([0, - wheel_radius + small_sphere_radius - inner_padding, 0]) {
			sphere(r=small_sphere_radius + inner_padding);
		}
		inner_axle_cutout(axle_diameter, pin_radius);
	}
	small_sphere(small_sphere_radius, [0, small_sphere_y, 0]);
	small_sphere(small_sphere_radius, [0, -small_sphere_y, 0]);
}

module small_sphere(small_sphere_radius, translate_by) {
	translate(translate_by) {
		sphere(r=small_sphere_radius);
	}
}

module ring(radius, thickness, height) {
	padding = 0.1;

	inner_radius = radius - thickness;

	difference() {
		cylinder(r=radius, h=height, center=true);
		cylinder(r=inner_radius, h=height + padding, center=true);
	}
}

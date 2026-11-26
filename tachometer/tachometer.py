#!/usr/bin/env python3

import math

from build123d import *
from ocp_vscode import *

motor_d = 20
motor_w = 15
motor_l = 25
motor_top_d = 6
motor_top_h = 2
motor_bottom_d = 10
motor_bottom_h = 2.3

shaft_d = 2
shaft_l = 44
shaft_top_l = 4

led_d = 5
led_h = 8.7
led_bottom_h = 1
led_bottom_d = 5.8
led_foot_distance = 2.54
led_foot_t = 0.5
led_anode_height = 28
led_cathode_height = 26

thickness = 2
tolerance = 0.1


attachment_t = 0.8
attachment_hole_offset = motor_w/2 + thickness + led_d/2
attachment_d = attachment_hole_offset*2 + led_d + thickness*2


def breadboard_compatible(dimension: float) -> float:
    return math.ceil(dimension / mount_grid) * mount_grid

mount_grid = 2.54
mount_width = breadboard_compatible(mount_grid * 4)
mount_spacing = thickness
mount_length = breadboard_compatible(led_h)
mount_motor_length = mount_length*3
mount_height = mount_spacing + thickness + led_d + thickness
mount_hole_dim = (0.64, 0.64, 5.5)
mount_attachment_distance = mount_grid/2

def create_motor():

    body = extrude( Circle(motor_d/2) & Rectangle(motor_d, motor_w), motor_l )

    top_housing = extrude( Plane( body.faces().sort_by().last ) * Circle(motor_top_d/2), motor_top_h )
    top_housing.label="top_housing"
    top_housing.color = Color("gray")
    
    bottom_housing = extrude( 
        Plane( body.faces().sort_by().first ) * 
        (Circle(motor_bottom_d/2) & Pos(0, -1) * Rectangle(motor_bottom_d, motor_bottom_d)), 
        motor_bottom_h
    )
    bottom_housing.label="bottom_housing"
    bottom_housing.color = Color("black")

    shaft = Pos(0,0,shaft_top_l) * Plane(top_housing.faces().sort_by().last) * Cylinder(shaft_d/2, shaft_l, align=(Align.CENTER, Align.CENTER, Align.MAX))
    shaft.label = "shaft"
    shaft.color = Color("gold")

    mount_face = body.faces().sort_by(Axis.Y)[0]
    mount_edge = mount_face.edges().sort_by(Axis.Z)[-1]

    mount_location = Plane(origin = mount_edge.center(), z_dir = mount_face.normal_at()).rotated((180,0,0)).location

    body = fillet(body.faces().sort_by().last.edges(), 1)
    body = fillet(body.faces().sort_by().first.edges(), 2)
    body.label = "body"
    body.color = Color("silver")

    compound = Compound(label="motor", children=[body, top_housing, bottom_housing, shaft])

    RigidJoint("mount", compound, mount_location)
    RigidJoint("attachment", compound, Plane(shaft.faces().sort_by()[-1]).location)

    return compound

def create_shaft_attachment():

    part = (
        extrude(Circle(attachment_d/2) - Pos(attachment_hole_offset, 0) * Circle(led_d/2), attachment_t) + 
        extrude((Circle(shaft_d/2 + thickness) - Circle(shaft_d/2)), attachment_t + shaft_top_l - tolerance)
    )
    part.label = "part"
    part.color = Color("black")

    compound = Compound(label="shaft_attachment", children=[part])

    RigidJoint("attachment", compound, Plane.XY.offset(attachment_t).rotated((180,0,90)).location)
    
    return compound

def create_led(color = "red"):

    bottom = extrude(Circle(led_bottom_d/2) - Pos(led_bottom_d/2+led_d/2,0) * Rectangle(led_bottom_d, led_bottom_d), led_bottom_h)
    middle = Plane((0, 0, bottom.faces().sort_by().last.center().Z)) * Cylinder(
        led_d/2, 
        led_h - led_bottom_h - led_d/2, 
        align=(Align.CENTER, Align.CENTER, Align.MIN)
    )
    top = Plane(middle.faces().sort_by().last) * Sphere(led_d/2)
    
    body = bottom + middle + top
    body.label = "body"
    body.color = Color(color)

    anode = Pos(-led_foot_distance/2, 0, -led_anode_height) * Box(led_foot_t, led_foot_t, led_anode_height, align=(Align.CENTER, Align.CENTER, Align.MIN))
    anode.label = "anode"
    anode.color = Color("silver")

    cathode = Pos(led_foot_distance/2, 0, -led_cathode_height) * Box(led_foot_t, led_foot_t, led_cathode_height, align=(Align.CENTER, Align.CENTER, Align.MIN))
    cathode.label = "cathode"
    cathode.color = Color("silver")

    compound = Compound(label="led", children=[body, anode, cathode])

    RigidJoint("mount", compound, Plane.XY.offset(led_bottom_h).location)

    return compound


def create_motor_assembly():
    motor = create_motor()
    shaft_attachment = create_shaft_attachment()

    motor.joints["attachment"].connect_to(shaft_attachment.joints["attachment"])
    compound = Compound(label="motor_assembly", children=[motor, shaft_attachment])

    attachment_center = shaft_attachment.faces().group_by()[-2][0].center()
    mount_location = motor.joints["mount"].location

    RigidJoint("left_mount", compound, mount_location * Pos(attachment_center.Z - mount_location.position.Z,0,0))
    RigidJoint("right_mount", compound, compound.joints["left_mount"].location * Rot(0,0,180))

    return compound


def create_led_mount(length: float = mount_length):
    box_align = (Align.MIN, Align.CENTER, Align.MIN)
    foot_align = (Align.CENTER, Align.CENTER, Align.MIN)
    
    box = Pos(length - mount_length,0,0) * Box(mount_length, mount_width, mount_height, 
        align=box_align)

    if length > mount_length:
        foot_locations = Locations(
            (mount_grid/2, (mount_width - mount_grid)/2), 
            (mount_grid/2, -(mount_width - mount_grid)/2)
        )
        foot = Box(mount_grid, mount_width, mount_height, align=box_align)

        box += Pos(0,0,mount_height-thickness) * Box(length, mount_width, thickness, align=box_align)
        box += foot
    else:
        foot_locations = Locations()

    led_cutter = Pos(0,0,mount_height-thickness-led_d/2) * Rot(0,90,0) * (
        Cylinder(led_bottom_d/2 + tolerance, length - led_h + led_bottom_h, align=foot_align) +
        Cylinder(led_d/2 + tolerance, length, align = foot_align)
    )
    box -= led_cutter

    pin = Box(mount_hole_dim[0] + tolerance*2, mount_hole_dim[1] + tolerance*2, mount_hole_dim[2], align=foot_align)
    pin_locations = Locations( 
        foot_locations.locations, 
        (Location((length - mount_length + mount_length/2,)) * loc for loc in GridLocations(mount_length - mount_grid, mount_width - mount_grid, 2, 2)) 
    )
    box -= (loc * pin for loc in pin_locations)

    fillet_edges = ( box.edges()
        .filter_by(Axis.X)
        .filter_by_position(Axis.Z, mount_height-thickness, mount_height-thickness)
        .filter_by_position(Axis.X, mount_grid, length)
    )

    if fillet_edges:
        box = fillet(fillet_edges, mount_grid / 2)


    compound = Compound(label="led_mount", children=[box])

    mount_face = box.faces().sort_by(Axis.Z)[-1]
    mount_edge = mount_face.edges().sort_by(Axis.X)[-1]

    RigidJoint("motor", compound, 
        Plane(origin = mount_edge.center(), z_dir = mount_face.normal_at())
            .move(Pos(mount_attachment_distance,0,0))
            .location
    )

    led_face = box.faces().sort_by(Axis.X).filter_by(lambda f: len(f.edges()) == 2)[-1]
    RigidJoint("led", compound, Plane(led_face).rotated((-90,0,180)).location)

    return compound

def create_mount_led_assembly(mount: Part, led: Part):
    mount.joints["led"].connect_to(led.joints["mount"])
    compound = Compound(label = "led_mount", children=[mount, led])
    RigidJoint("motor", compound, mount.joints["motor"].location)
    return compound

def create_assembly():
    motor = create_motor_assembly()

    left_mount = create_mount_led_assembly(
        create_led_mount(mount_motor_length),
        create_led("black")
    )
    left_mount.joints["motor"].connect_to(motor.joints["left_mount"])

    right_mount = create_mount_led_assembly(
        create_led_mount(mount_length),
        create_led("silver")
    )
    motor.joints["right_mount"].connect_to(right_mount.joints["motor"])

    return Compound(label = "assembly", children=[motor, left_mount, right_mount])


def export_printables():
    export_step(create_led_mount(mount_motor_length).rotate(Axis.X, 180), "motor_mount.step")
    export_step(create_led_mount(mount_length).rotate(Axis.X, 180), "led_mount.step")
    export_step(create_shaft_attachment(), "shaft_attachment.step")


show_object(create_assembly(), axes=True, reset_camera=Camera.KEEP, render_joints=True)
# show_object(create_led_mount(mount_motor_length), axes=True, reset_camera=Camera.KEEP, render_joints=True) 

#export_printables()

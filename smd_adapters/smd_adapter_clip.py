#!/usr/bin/env python3
"""SMD -> DIP adapter clip.

Port of ``smd_adapter_clip.scad`` to build123d (algebra mode).

The clip holds the adapter PCB and surrounds the SMD footprint.  It is built
from a 2D cross-section (the "omega" profile that wraps around the board)
extruded along Y, with a rectangular cut-out for the chip and an optional
"foot" that frames the footprint.
"""

import math
from dataclasses import dataclass
from typing import cast

from build123d import *

DIM_SCALE = 2.54

BOARD_THICKNESS = 1.5

THICKNESS = 2.0
FOOT_HEIGHT = 0.4
LOCK_HEIGHT = 0.4
FOOT_WIDTH_MAX = 1.5
FOOT_LENGTH_ADD = 1.0
# Flat silicone contact strip: ~1.0 mm thick, 0.6-0.7 mm wide.  It is a
# press fit into the 0.5 x 0.6 mm pocket, so no glue is needed.
SEAT_WIDTH = 0.5
SEAT_DEPTH = 0.6
ANGLE = 45.0


@dataclass(frozen=True)
class AdapterSize:
    """Dimensions of one adapter, all in mm.

    ``clip`` is the board-side footprint (width along X, length along Y),
    ``chip`` is the SMD body cut-out (width along X, length along Y).
    """

    clip: tuple[float, float]
    chip: tuple[float, float]


# name -> (clip footprint, chip body), mirroring the SCAD ``sizes`` table
PRESETS: dict[str, AdapterSize] = {
    "sot23": AdapterSize(clip=(3 * DIM_SCALE, 2 * DIM_SCALE), chip=(3.0, 1.7)),
    "sop8": AdapterSize(clip=(4 * DIM_SCALE, 3 * DIM_SCALE), chip=(5.0, 5.1)),
    "sop14": AdapterSize(clip=(7 * DIM_SCALE, 4 * DIM_SCALE), chip=(9.0, 5.1)),
}


def clip_width(clip_dim: tuple[float, float], x: float) -> float:
    """Cavity width at a profile step.

    ``x`` is the signed vertical span contributing to the taper:
    ``BOARD_THICKNESS`` at the board mid-plane, ``-2*FOOT_HEIGHT`` at the
    top of the cavity and ``-2*LOCK_HEIGHT`` at the lock.
    """
    return clip_dim[0] + x * math.tan(math.radians(ANGLE))


def clip_cavity(clip_dim: tuple[float, float]) -> Sketch:
    """Profile of the slot the adapter PCB sits in (drawn in the XY plane)."""
    top_z = BOARD_THICKNESS / 2 + FOOT_HEIGHT
    bottom_z = -BOARD_THICKNESS / 2 - LOCK_HEIGHT

    top_half = clip_width(clip_dim, -2 * FOOT_HEIGHT) / 2
    mid_half = clip_width(clip_dim, BOARD_THICKNESS) / 2
    bottom_half = clip_width(clip_dim, -2 * LOCK_HEIGHT) / 2

    points = [
        (-bottom_half, bottom_z),
        (-mid_half, 0.0),
        (-top_half, top_z),
        (top_half, top_z),
        (mid_half, 0.0),
        (bottom_half, bottom_z),
    ]
    return Polygon(*points)


def clip_profile(clip_dim: tuple[float, float]) -> Sketch:
    """Material cross-section: the cavity grown outward by THICKNESS.

    A mitered 2D offset (``Kind.INTERSECTION``) gives exactly the outer
    contour that used to be computed by hand with ``2 / cos(angle)`` and
    ``tan(45 - angle / 2)``. The offset also grows below the open slot, so
    that part is trimmed off flush with the bottom of the lip.
    """
    cavity = clip_cavity(clip_dim)

    bottom_z = -BOARD_THICKNESS / 2 - LOCK_HEIGHT
    outer_top_z = BOARD_THICKNESS / 2 + FOOT_HEIGHT + THICKNESS

    # Generously wide mask that keeps only the part above the slot opening.
    keep_above_slot = Pos(0, bottom_z) * Rectangle(
        2 * (clip_dim[0] + 2 * THICKNESS),
        outer_top_z - bottom_z,
        align=(Align.CENTER, Align.MIN),
    )

    wall = offset(cavity, THICKNESS, kind=Kind.INTERSECTION) - cavity
    return cast(Sketch, wall & keep_above_slot)


def contact_strip(size: AdapterSize) -> tuple[float, float, float]:
    """X length, Y width and Y centre of the lead-contact strip."""
    width = min(size.clip[1], size.chip[1] + FOOT_WIDTH_MAX * 2)
    strip_y = (width - size.chip[1]) / 2
    strip_x = size.chip[0] + FOOT_LENGTH_ADD * 2
    center_y = size.chip[1] / 2 + strip_y / 2
    return strip_x, strip_y, center_y


def clip_body(size: AdapterSize) -> Part:
    """Extruded profile with the chip cut-out."""
    clip_length = size.clip[1]
    body = extrude(Plane.XZ * clip_profile(size.clip), amount=clip_length / 2, both=True)
    # Cut the chip window through the whole body; Until.LAST finds the far
    # face of the target, so no guessed cut depth or center is needed.
    body -= extrude(
        Plane.XY.offset(body.bounding_box().min.Z) * Rectangle(size.chip[0], size.chip[1]), 
        until=Until.LAST, 
        target=body
    )
    return cast(Part, body)


def clip_foot(size: AdapterSize) -> Part | None:
    """Two pads pressing the SMD leads against the PCB pads.

    Only the part below the bridge is needed.  The old frame and the extra
    ``THICKNESS``-tall column existed solely to make the OpenSCAD union
    robust; here the pads simply meet the bridge's bottom face.
    """
    strip_x, strip_y, center_y = contact_strip(size)
    if strip_y <= 1e-9:
        return None

    # Wrapping the algebra result in Sketch keeps it a Sketch even when the
    # two disjoint strips would otherwise fuse into a bare Compound.
    pads = Sketch(
        Pos(0, center_y) * Rectangle(strip_x, strip_y)
        + Pos(0, -center_y) * Rectangle(strip_x, strip_y)
    )
    return extrude(Pos(0, 0, BOARD_THICKNESS / 2) * pads, amount=FOOT_HEIGHT)


def clip_seat(size: AdapterSize) -> Part:
    """Clip with shallow seats for a silicone contact strip.

    Instead of the rigid PETG pads, two 0.5 x 0.6 mm pockets are cut into
    the bridge underside.  A ~1.0 mm thick silicone strip (0.6-0.7 mm wide,
    cut to ``strip_x``) is pressed into each pocket.  The press fit holds it
    without glue; it protrudes ~0.4 mm and is compressed ~0.2 mm by the
    SMD leads.
    """
    strip_x, strip_y, center_y = contact_strip(size)
    seat_width = min(SEAT_WIDTH, strip_y)
    top_z = BOARD_THICKNESS / 2 + FOOT_HEIGHT

    body = clip_body(size)
    for sign in (1, -1):
        body -= Pos(0, sign * center_y, top_z) * Box(
            strip_x,
            seat_width,
            SEAT_DEPTH,
            align=(Align.CENTER, Align.CENTER, Align.MIN),
        )
    return cast(Part, body)


def clip(size: AdapterSize, with_foot: bool = True) -> Part:
    part = clip_body(size)
    if with_foot:
        part += clip_foot(size)
    return part


def printable(part: Part) -> Part:
    """Flip the part so the open side faces down for printing."""
    return Rot(180, 0, 0) * part

from ocp_vscode import show

preset = PRESETS["sop8"]


# show(clip(preset))       # rigid PETG pads
show(clip_seat(preset))    # seats for a silicone contact strip


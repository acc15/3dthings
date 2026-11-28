"""SMD -> DIP adapter clip.

Port of ``smd_adapter_clip.scad`` to build123d (algebra mode).

``Clip`` is a builder: ``Footprint`` (SOT-23, SOP, ...) resolves the
package-specific dimensions into a ``Config``, and the constructor applies
explicit overrides on top.  The geometry is a 2D cross-section (the "omega"
profile that wraps around the board) extruded along Y, with a rectangular
cut-out for the chip.  Lead contacts are built as separate solids and composed
with plain algebra: add ``feet()`` to the body or cut ``seats()`` into it.
"""
from dataclasses import dataclass
from typing import Any

from build123d import *
from ocp_vscode import show

from config import Config, Footprint, Sop, Sot23


@dataclass(frozen=True, slots=True, init=False)
class Clip:
    """A clip built from a footprint and explicit config overrides.

    ``Clip(Sop(8))`` resolves the footprint against the default config.
    ``Clip(Sop(14), thickness=2.2)`` applies overrides on both sides of the
    resolution: before, so inputs such as ``dip_pitch``, ``clip`` and
    ``board`` affect the derived dimensions, and after, so explicit values
    such as ``chip`` or ``name`` always win.

    The resulting ``cfg`` is frozen; the geometry methods read it directly.
    """

    cfg: Config

    def __init__(
        self,
        footprint: Footprint,
        cfg: Config | None = None,
        **overrides: Any,
    ) -> None:
        object.__setattr__(self, "cfg", footprint.build(cfg, **overrides))

    def profile(self) -> Sketch:
        """Material cross-section: the cavity grown outward by ``thickness``.

        The cavity is the slot the adapter PCB sits in: ``clip[0]`` is its
        width at the board faces, and the walls taper at ``angle`` away from
        the widest mid-plane.  A mitered 2D offset (``Kind.INTERSECTION``)
        gives exactly the outer contour that used to be computed by hand with
        ``2 / cos(angle)`` and ``tan(45 - angle / 2)``.  The offset also grows
        below the open slot, so that part is trimmed off flush with the lip.
        """
        cfg = self.cfg
        half = cfg.clip[0] / 2
        # Right half bottom to top, then its mirror top to bottom: the contour
        # is counter-clockwise, so the face normal is +Z.
        side = [
            (half - cfg.lock_height * cfg.taper, cfg.bottom_z),
            (half + cfg.board_half * cfg.taper, 0.0),
            (half - cfg.contact_height * cfg.taper, cfg.top_z),
        ]
        cavity = Polygon(*(side + [(-x, z) for x, z in reversed(side)]))

        grown = offset(cavity, cfg.thickness, kind=Kind.INTERSECTION)
        bbox = grown.bounding_box()
        # Trim the part of the offset that grew below the slot opening.
        keep_above_slot = Pos(0, cfg.bottom_z) * Rectangle(
            bbox.size.X,
            bbox.max.Y - cfg.bottom_z,
            align=(Align.CENTER, Align.MIN),
        )

        return Sketch((grown & keep_above_slot) - cavity)

    def body(self) -> Part:
        """Clip body around the adapter board, with the chip window cut out."""
        cfg = self.cfg
        part = extrude(
            Plane.XZ * self.profile(),
            amount=cfg.clip[1] / 2,
            both=True,
        )

        # The window cuts only the bridge; below it the cavity is already open.
        part -= extrude(
            cfg.bridge * Rectangle(cfg.chip[0], cfg.chip[1]),
            amount=-cfg.thickness,
        )
        return Part(part)

    def pcb(self) -> Part:
        """Preview-only adapter PCB; not part of the printed clip."""
        cfg = self.cfg
        return Box(cfg.board[0], cfg.board[1], cfg.board_thickness)

    def _contacts(self, width: float, amount: float) -> Part:
        """Two lead contacts on the bridge underside, mirrored across the chip.

        Both start at the chip window edge and extend outward by ``width``
        into the exposed PCB strip, so they must fit inside that band.
        ``amount`` grows along the cavity-facing bridge normal: a positive
        value adds material downwards, a negative one cuts upwards.
        """
        cfg = self.cfg
        if not 0 < width <= cfg.band_y:
            raise ValueError(
                f"{width:.2f} mm contacts do not fit in a "
                f"{cfg.band_y:.2f} mm band"
            )

        # Full cavity width at the bridge underside (the profile's top edge).
        strip_x = cfg.clip[0] - 2 * cfg.contact_height * cfg.taper
        center_y = cfg.chip[1] / 2 + width / 2

        return extrude(
            cfg.bridge * Sketch(
                Pos(0, sign * center_y) * Rectangle(strip_x, width)
                for sign in (1, -1)
            ),
            amount=amount,
        )

    def feet(self) -> Part:
        """Rigid pads on the bridge underside, pressing the leads onto the PCB."""
        cfg = self.cfg
        return self._contacts(
            min(cfg.foot_width_max, cfg.band_y),
            cfg.contact_height,
        )

    def seats(self) -> Part:
        """Pockets in the bridge underside for a silicone contact strip.

        A ~1.0 mm thick silicone strip (0.6-0.7 mm wide, cut to ``strip_x``)
        is pressed into each pocket: the press fit holds it without glue, it
        protrudes ~0.4 mm and is compressed ~0.2 mm by the SMD leads.
        """
        return self._contacts(self.cfg.seat_width, -self.cfg.seat_depth)

    def body_seats(self) -> Part:
        return Part(self.body() - self.seats())

    def body_feet(self) -> Part:
        return Part(self.body() + self.feet())


def printable(part: Part) -> Part:
    """Flip the part so the open side faces down for printing."""
    return Rot(180, 0, 0) * Part(part)


if __name__ == "__main__":
    presets = (Sot23(), Sop(8), Sop(14))
    clip = Clip(Sop(8))
    show(
        clip.body_seats(),
        clip.pcb(),
        names=["clip", "PCB (preview only)"],
        colors=["#b8b8b8", "#2e8b57"],
        alphas=[1.0, 0.65],
    )
    # show(clip.body_seats())  # silicone contact pockets
    # show(clip.body())        # bare clip

    # Batch export example:
    # for preset in presets:
    #     clip = Clip(preset)
    #     export_step(printable(clip.body_seats()), f"{clip.cfg.name}_seats.step")
    #     export_step(printable(clip.body_feet()), f"{clip.cfg.name}_feet.step")

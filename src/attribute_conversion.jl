struct Key{K} end
macro key_str(arg)
    :(Key{$(QuoteNode(Symbol(arg)))})
end

attribute_convert(x, key::Key, ::Key) = attribute_convert(x, key)
attribute_convert(s::Scene, x, key::Key, ::Key) = attribute_convert(s, x, key)
attribute_convert(s::Scene, x, key::Key) = attribute_convert(x, key)
attribute_convert(x, key::Key) = x

attribute_convert(c::Colorant, ::key"color") = RGBA{Float32}(c)
attribute_convert(c::Symbol, k::key"color") = attribute_convert(string(c), k)
attribute_convert(c::String, ::key"color") = parse(RGBA{Float32}, c)
attribute_convert(c::Union{Tuple, AbstractArray}, k::key"color") = attribute_convert.(c, k)
function attribute_convert(c::Tuple{T, F}, k::key"color") where {T, F <: Number}
    col = attribute_convert(c[1], k)
    RGBAf0(Colors.color(col), c[2])
end
attribute_convert(c::Billboard, ::key"rotations") = Vec4f0(0, 0, 0, 1)
attribute_convert(c, ::key"markersize", ::key"scatter") = Vec2f0(c)
attribute_convert(c, ::key"markersize", ::key"meshscatter") = Vec3f0(c)
attribute_convert(c, ::key"glowcolor") = attribute_convert(c, key"color"())
attribute_convert(c, ::key"strokecolor") = attribute_convert(c, key"color"())

attribute_convert(x::Void, ::key"linestyle") = x

"""
`AbstractVector{<:AbstractFloat}` for denoting sequences of fill/nofill. E.g.
[0.5, 0.8, 1.2] will result in 0.5 filled, 0.3 unfilled, 0.4 filled. 1.0 unit is one linewidth!
"""
attribute_convert(A::AbstractVector, ::key"linestyle") = A
"""
A `Symbol` equal to `:dash`, `:dot`, `:dashdot`, `:dashdotdot`
"""
function attribute_convert(ls::Symbol, ::key"linestyle")
    return if ls == :dash
        [0.0, 1.0, 2.0, 3.0, 4.0]
    elseif ls == :dot
        tick, gap = 1/2, 1/4
        [0.0, tick, tick+gap, 2tick+gap, 2tick+2gap]
    elseif ls == :dashdot
        dtick, dgap = 1.0, 1.0
        ptick, pgap = 1/2, 1/4
        [0.0, dtick, dtick+dgap, dtick+dgap+ptick, dtick+dgap+ptick+pgap]
    elseif ls == :dashdotdot
        dtick, dgap = 1.0, 1.0
        ptick, pgap = 1/2, 1/4
        [0.0, dtick, dtick+dgap, dtick+dgap+ptick, dtick+dgap+ptick+pgap, dtick+dgap+ptick+pgap+ptick,  dtick+dgap+ptick+pgap+ptick+pgap]
    else
        error("Unkown line style: $linestyle. Available: :dash, :dot, :dashdot, :dashdotdot or a sequence of numbers enumerating the next transparent/opaque region")
    end
end


attribute_convert(c::VecTypes{N}, ::key"position") where N = Point{N, Float32}(c)


function alignment2num(x::Symbol)
    (x == :center) && return 0.5f0
    (x in (:left, :bottom)) && return 0.0f0
    (x in (:right, :top)) && return 1.0f0
    0.0f0 # 0 default, or better to error?
end

"""
Text align, e.g. :
"""
attribute_convert(x::Tuple{Symbol, Symbol}, ::key"align") = Vec2f0(alignment2num.(x))
attribute_convert(x::Vec2f0, ::key"align") = x


"""
    font conversion
a string naming a font, e.g. helvetica
"""
function attribute_convert(x::Union{Symbol, String}, ::key"font")
    str = string(x)
    if str == "default"
        return GLVisualize.defaultfont()
    end
    newface(format(match(Fontconfig.Pattern(string(x))), "%{file}"))
end
attribute_convert(x::Font, ::key"font") = x




"""
    rotation accepts:
    to_rotation(b, quaternion)
    to_rotation(b, tuple_float)
    to_rotation(b, vec4)
"""
attribute_convert(s::Quaternions.Quaternion, ::key"rotation") = Vec4f0(s.v1, s.v2, s.v3, s.s)
attribute_convert(s::VecTypes{4}, ::key"rotation") = Vec4f0(s)
attribute_convert(s::Tuple{<:VecTypes{3}, <: AbstractFloat}, ::key"rotation") = qrotation(s[1], s[2])
attribute_convert(s::Tuple{<:VecTypes{2}, <: AbstractFloat}, ::key"rotation") = qrotation(Vec3f0(s[1][1], s[1][2], 0), s[2])
attribute_convert(angle::AbstractFloat, ::key"rotation") = qrotation(Vec3f0(0, 0, 1), angle)
attribute_convert(r::AbstractVector, k::key"rotation") = attribute_convert.(r, k)


attribute_convert(x, k::key"textsize") = Float32(x)

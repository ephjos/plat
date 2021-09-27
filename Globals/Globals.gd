extends Node

const DEBUG = false

const TILE_SIZE = 16 # px
const GRAVITY = 1200
const UP = Vector2(0, -1)

var PLAYER = null
var GOAL = null
var CAMERA = null

var LEVEL_COMPLETE = false


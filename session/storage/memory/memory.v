module memory

pub struct Storage {
mut:
	mux sync.RwMutex
}

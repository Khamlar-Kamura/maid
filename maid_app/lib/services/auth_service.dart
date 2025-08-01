/*const Text(
                      'ທ່ານຢາກໃຫ້ບໍລິການຢູ່ທີ່ໃດ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'ລະບຸສະຖານທີ່ (Location)',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 180,
                      child: _selectedPosition == null
                          ? const Center(child: CircularProgressIndicator())
                          : FlutterMap(
                              options: MapOptions(
                                initialCenter: _selectedPosition!,
                                initialZoom: 14,
                                onTap: (tapPosition, point) {
                                  setState(() {
                                    _selectedPosition = point;
                                    locationController.text =
                                        '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
                                  });
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c'],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: 40,
                                      height: 40,
                                      point: _selectedPosition!,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),*/
// Widget _buildFileCard(PlatformFile file) {
//   return Container(
//     decoration: BoxDecoration(color: Colors.white),
//     child: Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(
//             vertical: 12.0,
//             horizontal: 16.0,
//           ),
//           decoration: BoxDecoration(
//             color: const Color.fromARGB(255, 255, 255, 255),
//             borderRadius: BorderRadius.circular(8.0),
//             border: Border.all(color: const Color(0xFFC6C6C6), width: 1),
//           ),
//           child: Text(
//             file.name,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w400,
//               fontFamily: "Noto Sans",
//               color: Color(0xFF212121),
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         const SizedBox(width: 12),
//         InkWell(
//           onTap: () {
//             setState(() {
//               _selectedFiles.remove(file);
//             });
//           },
//           child: Container(
//             padding: const EdgeInsets.all(4),
//             child: const Icon(
//               Icons.delete_outline_rounded,
//               color: Color(0xFFE53935),
//               size: 24,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

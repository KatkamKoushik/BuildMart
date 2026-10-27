import 'package:flutter/material.dart';

String translateCategory(BuildContext context, String englishName) {
  final locale = Localizations.localeOf(context).languageCode;

  if (locale == 'te') {
    switch (englishName) {
      case 'Bricks & Blocks':
        return 'ఇటుకలు & బ్లాక్‌లు';
      case 'Cement':
        return 'సిమెంట్';
      case 'Doors & Glass':
        return 'తలుపులు & గ్లాస్';
      case 'Electricals':
        return 'ఎలక్ట్రికల్స్';
      case 'Fasteners':
        return 'ఫాస్టెనర్లు';
      case 'Hardware & Tools':
        return 'హార్డ్‌వేర్ & టూల్స్';
      case 'Paints':
        return 'పెయింట్స్';
      case 'Plumbing':
        return 'ప్లంబింగ్';
      case 'Roofing':
        return 'రూఫింగ్';
      case 'Safety Equipment':
        return 'భద్రతా పరికరాలు';
      case 'Sand & Aggregates':
        return 'ఇసుక & కంకర';
      case 'Site Materials':
        return 'సైట్ మెటీరియల్స్';
      case 'Steel':
        return 'స్టీల్';
      case 'Tiles & Flooring':
        return 'టైల్స్ & ఫ్లోరింగ్';
      case 'Water Tanks':
        return 'వాటర్ ట్యాంకులు';
      case 'Wood & Timber':
        return 'కలప';
    }
  } else if (locale == 'hi') {
    switch (englishName) {
      case 'Bricks & Blocks':
        return 'ईंटें और ब्लॉक';
      case 'Cement':
        return 'सीमेंट';
      case 'Doors & Glass':
        return 'दरवाजे और कांच';
      case 'Electricals':
        return 'इलेक्ट्रिकल्स';
      case 'Fasteners':
        return 'फास्टेनर्स';
      case 'Hardware & Tools':
        return 'हार्डवेयर और टूल्स';
      case 'Paints':
        return 'पेंट्स';
      case 'Plumbing':
        return 'प्लंबिंग';
      case 'Roofing':
        return 'छत (Roofing)';
      case 'Safety Equipment':
        return 'सुरक्षा उपकरण';
      case 'Sand & Aggregates':
        return 'रेत और गिट्टी';
      case 'Site Materials':
        return 'साइट सामग्री';
      case 'Steel':
        return 'स्टील';
      case 'Tiles & Flooring':
        return 'टाइल्स और फ्लोरिंग';
      case 'Water Tanks':
        return 'पानी की टंकियां';
      case 'Wood & Timber':
        return 'लकड़ी';
    }
  }

  return englishName;
}

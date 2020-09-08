import { Controller } from "stimulus"

export default class extends Controller {
  playSong(event) {
    event.preventDefault();
    event.stopPropagation();
    const song = event.currentTarget;
    song.audio = new Audio(song.href);
    song.audio.play();
  }
}
